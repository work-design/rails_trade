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
        purchase: 'purchase',
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
      has_many :items, ->(o) { where(o.filter_hash).carting.order(id: :asc) }, primary_key: :organ_id, foreign_key: :organ_id, inverse_of: :current_cart  # 用于购物车展示，计算
      has_many :all_items, ->(o) { where(o.filter_hash) }, class_name: 'Item', primary_key: :organ_id, foreign_key: :organ_id
      has_many :organ_items, ->(o) { where(o.in_filter_hash).carting }, class_name: 'Item', primary_key: :member_organ_id, foreign_key: :member_organ_id, inverse_of: :current_cart
      has_many :agent_items, ->(o) { where(o.agent_filter_hash).carting }, class_name: 'Item', primary_key: :organ_id, foreign_key: :organ_id
      has_many :current_items, class_name: 'Item', foreign_key: :current_cart_id
      has_many :trial_card_items, ->(o) { where(**o.filter_hash, good_type: 'Trade::Purchase', aim: 'use', status: 'trial') }, class_name: 'Item', primary_key: :organ_id, foreign_key: :organ_id, inverse_of: :current_cart

      has_many :cart_promotes, -> { where(order_id: nil) }, inverse_of: :cart
      has_many :deliveries, ->(o) { where(o.simple_filter_hash) }, primary_key: :organ_id, foreign_key: :organ_id
      has_many :orders, ->(o) { where(o.simple_filter_hash) }, foreign_key: :organ_id, primary_key: :organ_id, inverse_of: :current_cart
      has_many :cards, ->(o) { where(o.simple_filter_hash) }, foreign_key: :organ_id, primary_key: :organ_id
      has_many :wallets, ->(o) { where(o.simple_filter_hash) }, foreign_key: :organ_id, primary_key: :organ_id
      has_one :lawful_wallet, ->(o) { where(o.simple_filter_hash) }, foreign_key: :organ_id, primary_key: :organ_id

      validates :deposit_ratio, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
      validates :good_type, presence: true

      before_validation :sync_original_amount, if: -> { (changes.keys & ['item_amount', 'overall_additional_amount', 'overall_reduced_amount']).present? }
      after_validation :sum_amount, if: -> { (changes.keys & ['item_amount', 'overall_additional_amount', 'overall_reduced_amount']).present? }
      after_save :sync_client_to_items, if: -> { respond_to?(:agent_id) && agent_id.present? && saved_change_to_client_id? }
    end

    def filter_hash
      p = { good_type: good_type, aim: aim }.compact
      if member_id
        p.merge! member_id: member_id
      elsif respond_to?(:contact_id) && contact_id
        p.merge! contact_id: contact_id, client_id: client_id
      elsif respond_to?(:client_id) && client_id
        p.merge! client_id: client_id
      elsif user_id
        p.merge! user_id: user_id
      else
        p.merge!({ member_organ_id: member_organ_id }.compact)
      end
      p.merge! agent_id: agent_id, client_id: client_id if respond_to? :agent_id
      p
    end

    def agent_filter_hash
      {
        good_type: good_type, aim: aim, agent_id: agent_id, client_id: nil
      }
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

    def agent_cart?

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
      logger.debug "\e[33m  Items: #{r.map(&->(i){ "#{i.id}/#{i.object_id}" })}, Cart id: #{id})  \e[0m"
      r
    end

    def checked_items
      items.select(&:effective?)
    end

    def compute_amount
      self.total_quantity = checked_items.sum(&->(i){ i.original_quantity.to_d })
      _checked_all_items = checked_all_items

      self.retail_price = _checked_all_items.sum(&->(i){ i.retail_price.to_d })
      self.discount_price = _checked_all_items.sum(&->(i){ i.discount_price.to_d })
      self.bulk_price = self.retail_price - self.discount_price

      self.item_amount = _checked_all_items.sum(&->(i){ i.original_amount.to_d })
      self.advance_amount = _checked_all_items.sum(&->(i){ i.advance_amount.to_d })
      self.overall_additional_amount = cart_promotes.select(&->(o){ o.amount >= 0 }).sum(&->(i){ i.amount.to_d })
      self.overall_reduced_amount = cart_promotes.select(&->(o){ o.amount < 0 }).sum(&->(i){ i.amount.to_d })  # 促销价格
      self.fresh = true
      self.changes
    end

    def sum_amount
      self.amount = item_amount + overall_additional_amount + overall_reduced_amount
    end

    def compute_amount!
      compute_amount
      save
    end

    def need_address?
      ['Factory::Production'].include?(good_type) && ['use', 'rent'].include?(aim)
    end

    def identity
      if member_id
        "_#{member_id}"
      elsif contact_id
        "_#{contact_id}"
      end
    end

    def has_address?
      if need_address?
        address.present?
      else
        true
      end
    end

    def all_checked?
      items.all?(&:status_checked?)
    end

    def toggle_all
      if all_checked?
        items.each do |item|
          item.update_columns status: 'init'
        end
      else
        items.select(&:status_init?).each do |item|
          item.update_columns status: 'checked'
        end
      end
      compute_amount!
    end

    def get_item(good_type:, good_id:, aim: 'use', number: 1, **options)
      args = { good_type: good_type, good_id: good_id, aim: aim, **options.slice(:produce_on, :scene_id) }
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
      args = attr_options(**options)
      items.find(&->(i){ i.attributes.slice(*args.keys) == args })
    end

    def find_items(goods, **options)
      result = {}
      goods.each do |good|
        item = find_item(good_id: good.id, **options)
        result.merge! good.id => item if item
      end
      result
    end

    def find_purchase_items(*purchase_ids, **options)
      args = attr_options(**options)
      items.select do |i|
        i.attributes.slice(*args.keys) == args && purchase_ids.include(i.purchase_id)
      end
    end

    def organ_item(**options)
      args = attr_options(**options)
      organ_items.find(&->(i){ i.attributes.slice(*args.keys) == args })
    end

    def attr_options(**options)
      options.symbolize_keys!
      args = { good_type: good_type, aim: aim }
      args.merge! options.slice(:good_type, :aim, :contact_id, :member_id)
      if options.key?(:good_id)
        if [nil, ''].include? options[:good_id]
          args.merge! good_id: nil
        else
          args.merge! good_id: options[:good_id].to_i
        end
      end
      if options.key?(:purchase_id)
        if [nil, ''].include? options[:purchase_id]
          args.merge! purchase_id: nil
        else
          args.merge! purchase_id: options[:purchase_id].to_i
        end
      end
      args.merge! scene_id: options[:scene_id].to_i if options[:scene_id]
      args.merge! produce_on: options[:produce_on].to_date if options[:produce_on]
      args.stringify_keys!
    end

    def sync_client_to_items
      agent_items.update_all(client_id: client_id)
      maintain = agent.maintains.find_or_initialize_by(client_id: client_id)
      maintain.state = 'carted'
      maintain.save
    end

  end
end
