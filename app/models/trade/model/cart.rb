module Trade
  module Model::Cart
    extend ActiveSupport::Concern
    include Inner::Amount
    include Inner::User

    included do
      attribute :good_type, :string
      attribute :retail_price, :decimal, default: 0, comment: '汇总：原价'
      attribute :discount_price, :decimal, default: 0, comment: '汇总：优惠'
      attribute :bulk_price, :decimal, default: 0
      attribute :total_quantity, :decimal, default: 0
      attribute :deposit_ratio, :integer, default: 100, comment: '最小预付比例'
      attribute :auto, :boolean, default: false, comment: '自动下单'
      attribute :items_count, :integer, default: 0
      attribute :fresh, :boolean, default: false

      enum aim: {
        use: 'use',
        invest: 'invest',
        rent: 'rent'
      }, _default: 'use', _prefix: true

      belongs_to :address, class_name: 'Profiled::Address', optional: true

      belongs_to :payment_strategy, optional: true

      has_many :available_promote_goods, -> { available }, class_name: 'PromoteGood'
      has_many :payment_references, ->(o) { where(o.filter_hash) }, primary_key: :organ_id, foreign_key: :organ_id
      has_many :payment_methods, through: :payment_references

      has_many :promote_good_users, ->(o) { where(o.filter_hash) }, foreign_key: :organ_id, primary_key: :organ_id
      has_many :promote_good_types, through: :promote_good_users
      has_many :items, ->(o) { where(o.filter_hash).carting }, primary_key: :organ_id, foreign_key: :organ_id, inverse_of: :current_cart  # 用于购物车展示
      has_many :checked_items, ->(o) { where(o.filter_hash).checked }, class_name: 'Item', primary_key: :organ_id, foreign_key: :organ_id, inverse_of: :current_cart  # 用于计算
      has_many :all_items, ->(o) { where(o.filter_hash) }, class_name: 'Item', primary_key: :organ_id, foreign_key: :organ_id
      has_many :organ_items, ->(o) { where(o.in_filter_hash).carting }, class_name: 'Item', primary_key: :member_organ_id, foreign_key: :member_organ_id, inverse_of: :current_cart
      has_many :current_items, class_name: 'Item', foreign_key: :current_cart_id
      has_many :trial_card_items, ->(o) { where(**o.filter_hash, good_type: 'Trade::Purchase', aim: 'use', status: 'trial') }, class_name: 'Item', primary_key: :organ_id, foreign_key: :organ_id, inverse_of: :current_cart

      has_many :cart_promotes, -> { where(order_id: nil) }, inverse_of: :cart
      has_many :deliveries, ->(o) { where(o.simple_filter_hash) }, primary_key: :organ_id, foreign_key: :organ_id
      has_many :orders, ->(o) { where(o.simple_filter_hash) }, foreign_key: :organ_id, primary_key: :organ_id
      has_many :cards, ->(o) { where(o.simple_filter_hash) }, foreign_key: :organ_id, primary_key: :organ_id
      has_many :wallets, ->(o) { where(o.simple_filter_hash) }, foreign_key: :organ_id, primary_key: :organ_id
      has_one :lawful_wallet, ->(o) { where(o.simple_filter_hash) }, foreign_key: :organ_id, primary_key: :organ_id

      validates :deposit_ratio, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
      validates :good_type, presence: true

      after_initialize :sync_from_maintain, if: -> { new_record? && maintain_id.present? }
      before_validation :sync_member_organ, if: -> { member_id_changed? && member }
      before_validation :sync_original_amount, if: -> { (changes.keys & ['item_amount', 'overall_additional_amount', 'overall_reduced_amount']).present? }
      after_validation :compute_amount, if: -> { (changes.keys & ['item_amount', 'overall_additional_amount', 'overall_reduced_amount']).present? }
    end

    def filter_hash
      if member_id
        { member_id: member_id, good_type: good_type, aim: aim }.compact
      elsif client_id
        { client_id: client_id, good_type: good_type, aim: aim }.compact
      elsif user_id
        { user_id: user_id, good_type: good_type, aim: aim }.compact
      else
        { member_organ_id: member_organ_id, good_type: good_type, aim: aim }.compact
      end
    end

    def simple_filter_hash
      if member_id
        { member_id: member_id }
      elsif client_id
        { client_id: client_id }
      elsif user_id
        { user_id: user_id, member_id: nil, client_id: nil }
      else
        { member_organ_id: member_organ_id, member_id: member_id }
      end
    end

    def in_filter_hash
      {
        good_type: good_type,
        aim: aim
      }
    end

    def in_cart?
      organ_id.blank? && member_organ.present?
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

    def owned?(card_template)
      cards.find_by(card_template_id: card_template.id, temporary: false)
    end

    def deposit_ratio_str
      deposit_ratio.to_fs(:percentage, precision: 0)
    end

    def owned_text(card_template)
      r = cards.find_by(card_template_id: card_template.id, temporary: false)
      if r.nil?
        '立即开通'
      elsif r.expired?
        '已过期'
      else
        '已开通'
      end
    end

    def available_card_templates
      effective_ids = cards.effective.where(temporary: false).pluck(:card_template_id)

      CardTemplate.enabled.where(organ_id: [organ_id, nil], parent_id: nil).where.not(id: effective_ids)
    end

    def add_purchase_item(card_template: available_card_templates.take)
      return unless card_template
      return if card_template.purchase.blank? || cards.effective.find_by(card_template_id: card_template.id)

      item = trial_card_items.build(
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
      if in_cart?
        r = organ_items.select(&:effective?) + trial_card_items.select(&->(i){ !i.destroyed? })
      else
        r = items.select(&:effective?) + trial_card_items.select(&->(i){ !i.destroyed? })
      end
      logger.debug "\e[33m  Item amount: #{item_amount}, Items: #{r.map(&->(i){ "#{i.id}/#{i.object_id}" })}, Summed amount: #{checked_items.sum(&->(i){ i.amount.to_d })}, Cart id: #{id})  \e[0m"
      r
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
      self.fresh = true
      self.changes
    end

    def compute_amount!
      compute_amount
      save
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

    def find_item(**options)
      args = xx(**options)
      logger.debug "\e[35m  #{args}  \e[0m"

      items.find(&->(i){ i.attributes.slice(*args.keys) == args })
    end

    def organ_item(**options)
      args = xx(**options)

      organ_items.find(&->(i){ i.attributes.slice(*args.keys) == args })
    end

    def xx(**options)
      options.symbolize_keys!
      args = { good_id: options[:good_id].to_i, good_type: good_type, aim: aim, **options.slice(:fetch_oneself) }
      args.merge! produce_on: options[:produce_on].to_date if options[:produce_on].present?
      args.merge! scene_id: options[:scene_id].to_i if options[:scene_id].present?
      args.stringify_keys!
    end

  end
end
