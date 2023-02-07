module Trade
  module Model::Cart
    extend ActiveSupport::Concern
    include Inner::Amount

    included do
      attribute :good_type, :string
      attribute :retail_price, :decimal, default: 0, comment: '汇总：原价'
      attribute :discount_price, :decimal, default: 0, comment: '汇总：优惠'
      attribute :bulk_price, :decimal, default: 0
      attribute :total_quantity, :decimal, default: 0
      attribute :deposit_ratio, :integer, default: 100, comment: '最小预付比例'
      attribute :auto, :boolean, default: false, comment: '自动下单'
      attribute :items_count, :integer, default: 0

      enum aim: {
        use: 'use',
        invest: 'invest',
        rent: 'rent'
      }, _default: 'use', _prefix: true

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true
      belongs_to :address, class_name: 'Profiled::Address', optional: true
      belongs_to :payment_strategy, optional: true

      belongs_to :maintain, class_name: 'Crm::Maintain', optional: true
      belongs_to :client, class_name: 'Profiled::Profile', optional: true

      has_many :orders, ->(o) { where(organ_id: o.organ_id, member_id: o.member_id) }, foreign_key: :user_id, primary_key: :user_id
      has_many :promote_goods, foreign_key: :user_id, primary_key: :user_id
      has_many :available_promote_goods, -> { available }, class_name: 'PromoteGood'
      has_many :payment_references, dependent: :destroy_async
      has_many :payment_methods, through: :payment_references

      has_many :deliveries, ->(o) { where(o.simple_filter_hash) }, primary_key: :user_id, foreign_key: :user_id
      has_many :items, ->(o) { where(o.filter_hash).carting }, primary_key: :user_id, foreign_key: :user_id  # 用于购物车展示
      has_many :checked_items, ->(o) { where(o.filter_hash).checked }, class_name: 'Item', primary_key: :user_id, foreign_key: :user_id, inverse_of: :current_cart  # 用于计算
      has_many :all_items, ->(o) { where(o.filter_hash) }, class_name: 'Item', primary_key: :user_id, foreign_key: :user_id
      has_many :organ_items, ->(o) { where({ good_type: o.good_type, aim: o.aim }.compact).carting }, class_name: 'Item', primary_key: :member_organ_id, foreign_key: :member_organ_id
      has_many :current_items, class_name: 'Item', foreign_key: :current_cart_id
      has_many :trial_card_items, ->(o) { where(**o.filter_hash, good_type: 'Trade::Purchase', aim: 'use').status_trial }, class_name: 'Item', primary_key: :user_id, foreign_key: :user_id

      has_many :cart_promotes, -> { where(order_id: nil) }, inverse_of: :cart
      has_many :cards, ->(o) { includes(:card_template).where(o.simple_filter_hash) }, foreign_key: :user_id, primary_key: :user_id
      has_many :wallets, -> { includes(:wallet_template).where(o.simple_filter_hash) }, foreign_key: :user_id, primary_key: :user_id
      has_one :wallet, -> { where(default: true) }, foreign_key: :user_id, primary_key: :user_id

      validates :deposit_ratio, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
      validates :good_type, presence: true

      after_initialize :sync_from_maintain, if: -> { new_record? && maintain_id.present? }
      before_validation :sync_member_organ, if: -> { member_id_changed? && member }
      before_validation :sync_original_amount, if: -> { (changes.keys & ['item_amount', 'overall_additional_amount', 'overall_reduced_amount']).present? }
      after_validation :compute_amount, if: -> { (changes.keys & ['item_amount', 'overall_additional_amount', 'overall_reduced_amount']).present? }
    end

    def filter_hash
      if user_id
        { organ_id: organ_id, member_id: member_id, good_type: good_type, aim: aim }.compact
      elsif client_id
        { organ_id: organ_id, client_id: client_id, good_type: good_type, aim: aim }.compact
      else
        { member_organ_id: member_organ_id, good_type: good_type, aim: aim }.compact
      end
    end

    def simple_filter_hash
      if user_id
        { organ_id: organ_id, member_id: member_id }
      elsif client_id
        { organ_id: organ_id, member_id: member_id, client_id: client_id }
      else
        { organ_id: organ_id, member_id: member_id }
      end
    end

    def sync_member_organ
      self.member_organ_id = member.organ_id
      self.user ||= member.user
    end

    def sync_from_maintain
      return unless maintain
      self.client_id = maintain.client_id
      self.user_id = maintain.client_user_id
      self.member_id = maintain.client_member_id
    end

    def sync_original_amount
      self.original_amount = item_amount + overall_additional_amount
    end

    def any_rent?
      items.any?(&->(i){ i.aim_rent? })
    end

    def owned?(card_template)
      cards.find_by(card_template_id: card_template.id, temporary: false)
    end

    def temp_owned?(card_template)
      cards.find_by(card_template_id: card_template.id, temporary: true)
    end

    def card_templates
      effective_ids = cards.effective.pluck(:card_template_id)

      if effective_ids.blank?
        CardTemplate.enabled.where(organ_id: [organ_id, nil], parent_id: nil)
      else
        CardTemplate.enabled.where(organ_id: [organ_id, nil], parent_id: nil).where.not(id: effective_ids)
      end
    end

    def add_purchase_item(card_template: card_templates.take)
      return if card_template.purchase.blank? || cards.find_by(card_template_id: card_template.id)

      item = Item.new(
        good_type: card_template.purchase.class_name,
        good_id: card_template.purchase.id,
        current_cart_id: self.id,
        status: 'trial',
        aim: 'use',
        user_id: user_id,
        member_id: member_id
      )
      item.save
      items.each(&:compute_price!)
    end

    def checked_all_items
      checked_items + trial_card_items
    end

    def compute_amount
      self.total_quantity = checked_items.sum(&->(i){ i.original_quantity.to_d })

      self.retail_price = checked_all_items.sum(&->(i){ i.retail_price.to_d })
      self.discount_price = checked_all_items.sum(&->(i){ i.discount_price.to_d })
      self.bulk_price = self.retail_price - self.discount_price

      self.item_amount = checked_all_items.sum(&->(i){ i.original_amount.to_d })
      self.overall_additional_amount = cart_promotes.select(&->(o){ o.amount >= 0 }).sum(&->(i){ i.amount.to_d })
      self.overall_reduced_amount = cart_promotes.select(&->(o){ o.amount < 0 }).sum(&->(i){ i.amount.to_d })  # 促销价格
      self.amount = item_amount + overall_additional_amount + overall_reduced_amount

      self.changes
    end

    def need_address?
      ['use', 'rent'].include?(aim)
    end

    def get_item(good_type:, good_id:, aim: 'use', number: 1, **options)
      args = { good_type: good_type, good_id: good_id, aim: aim, **options.slice(:produce_on, :scene_id, :fetch_oneself) }
      args.reject!(&->(_, v){ v.blank? })
      item = find_item(**args) || items.build(args)

      if item.persisted? && item.status_checked?
        item.number += (number.present? ? number.to_i : 1)
      elsif item.persisted? && item.status_init?
        item.status = 'checked'
        item.number = 1
      else
        item.status = 'checked'
      end

      item
    end

    def find_item(good_id:, **options)
      args = xx(good_id: good_id, **options)

      items.find(&->(i){ i.attributes.slice(*args.keys) == args })
    end

    def organ_item(good_id:, **options)
      args = xx(good_id: good_id, **options)

      organ_items.find(&->(i){ i.attributes.slice(*args.keys) == args })
    end

    def xx(good_id:, **options)
      args = { good_id: good_id, good_type: good_type, aim: aim, **options.slice(:fetch_oneself) }
      args.merge! produce_on: options[:produce_on].to_date if options[:produce_on].present?
      args.merge! scene_id: options[:scene_id].to_i if options[:scene_id].present?
      args.stringify_keys!
    end

  end
end
