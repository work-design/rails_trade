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
      attribute :fresh, :boolean, default: false
      attribute :purchasable, :boolean, default: false
      attribute :items_count, :integer, default: 0

      enum :aim, {
        use: 'use',
        invest: 'invest',
        rent: 'rent'
      }, default: 'use', prefix: true

      belongs_to :address, class_name: 'Ship::Address', optional: true

      belongs_to :payment_strategy, optional: true

      has_many :available_promote_goods, -> { available }, class_name: 'PromoteGood'
      has_many :payment_references, ->(o) { where(o.filter_hash) }, primary_key: :organ_id, foreign_key: :organ_id
      has_many :payment_methods, through: :payment_references

      has_many :promote_goods, ->(o) { where(o.promote_filter_hash) }, primary_key: :good_type, foreign_key: :good_type
      has_many :real_items, ->(o) { where(o.filter_hash).carting }, class_name: 'Item', primary_key: :organ_id, foreign_key: :organ_id, inverse_of: :current_cart  # 用于购物车展示，计算
      has_many :all_items, ->(o) { where(o.filter_hash) }, class_name: 'Item', primary_key: :organ_id, foreign_key: :organ_id
      has_many :organ_items, ->(o) { where(o.in_filter_hash).where(purchase_id: nil).carting }, class_name: 'Item', primary_key: :member_organ_id, foreign_key: :member_organ_id, inverse_of: :purchase_cart
      has_many :purchase_items, ->(o) { where(o.in_filter_hash).where.not(purchase_id: nil).carting }, class_name: 'Item', primary_key: :member_organ_id, foreign_key: :member_organ_id, inverse_of: :current_cart
      has_many :agent_items, -> { carting }, class_name: 'Item', primary_key: [:good_type, :aim, :agent_id, :contact_id, :client_id, :desk_id, :station_id], foreign_key: [:good_type, :aim, :agent_id, :contact_id, :client_id, :desk_id, :station_id], inverse_of: :current_cart
      has_many :current_items, class_name: 'Item', foreign_key: :current_cart_id
      has_many :trial_card_items, ->(o) { where(**o.filter_hash, good_type: 'Trade::Purchase', aim: 'use', status: 'trial') }, class_name: 'Item', primary_key: :organ_id, foreign_key: :organ_id, inverse_of: :current_cart

      has_many :cart_promotes, -> { where(order_id: nil) }, inverse_of: :cart, autosave: true
      has_many :deliveries, ->(o) { where(o.simple_filter_hash) }, primary_key: :organ_id, foreign_key: :organ_id
      has_many :orders, ->(o) { where(o.simple_filter_hash) }, foreign_key: :organ_id, primary_key: :organ_id, inverse_of: :current_cart
      has_many :cards, ->(o) { where(o.simple_filter_hash) }, foreign_key: :organ_id, primary_key: :organ_id
      has_many :wallets, ->(o) { where(o.simple_filter_hash) }, foreign_key: :organ_id, primary_key: :organ_id
      has_one :lawful_wallet, ->(o) { where(o.simple_filter_hash) }, foreign_key: :organ_id, primary_key: :organ_id

      validates :deposit_ratio, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
      validates :good_type, presence: true

      before_validation :sync_original_amount, if: -> { (changes.keys & ['item_amount', 'overall_additional_amount', 'overall_reduced_amount']).present? }
      after_validation :sum_amount, if: -> { (changes.keys & ['item_amount', 'overall_additional_amount', 'overall_reduced_amount']).present? }
    end

    def filter_hash
      p = { good_type: good_type, aim: aim }.compact

      if member_id
        p.merge! member_id: member_id
      elsif respond_to?(:contact_id) && contact_id
        p.merge! contact_id: contact_id, client_id: client_id, agent_id: agent_id
      elsif respond_to?(:client_id) && client_id
        p.merge! client_id: client_id, agent_id: agent_id
      elsif respond_to?(:agent_id) && agent_id
        p.merge! agent_id: agent_id
      elsif user_id
        p.merge! user_id: user_id
      elsif member_organ_id
        p.merge! member_organ_id: member_organ_id
      end

      if respond_to? :desk_id
        p.merge! desk_id: desk_id, station_id: station_id
      end

      p
    end

    def agent_filter_hash
      {
        good_type: good_type,
        aim: aim,
        contact_id: contact_id,
        client_id: client_id,
        desk_id: desk_id,
        station_id: station_id
      }
    end

    def in_filter_hash
      {
        good_type: good_type,
        aim: aim
      }
    end

    def promote_filter_hash
      {
        organ_id: organ&.self_and_ancestor_ids,
        user_id: [user_id, nil].uniq,
        member_id: [member_id, nil].uniq,
        card_template_id: cards.map(&:card_template_id).uniq.append(nil),
        card_id: card_ids.append(nil),
        aim: aim
      }
    end

    def items
      if purchasable
        purchase_items
      elsif organ_id.blank? && member_organ.present?
        organ_items
      elsif agent_id.present?
        agent_items
      else
        real_items
      end
    end

    def cart_items
      r = items.select(&:persisted?)
      ActiveRecord::Associations::Preloader.new(records: r, associations: [:item_promotes, :good]).call
      r.sort_by! { |i| i.id }
      r
    end

    def checked_items
      r = items.select(&:effective?)
      ActiveRecord::Associations::Preloader.new(records: r, associations: [:item_promotes, :good]).call
      r
    end

    def checked_all_items
      r = checked_items + trial_card_items.select(&->(i){ !i.destroyed? })
      logger.debug "\e[33m  Items: #{r.map(&->(i){ "#{i.id}/#{i.object_id}" })}, Cart id: #{id})  \e[0m"
      r
    end

    def checked_item_ids
      checked_items.pluck(:id)
    end

    def available_item_promotes
      r = []
      checked_items.each do |checked_item|
        r += checked_item.item_promotes
      end

      r
    end

    def support_deposit?
      deposit_ratio < 100 && deposit_ratio > 0
    end

    def need_address?
      checked_all_items.map(&:dispatch).include?('delivery')
    end

    def can_order?
      checked_item_ids.compact.present? && has_address?
    end

    def has_address?
      if agent_id.present?
        true
      elsif need_address?
        address.present?
      else
        true
      end
    end

    def all_checked?
      items.all?(&:status_checked?)
    end

    def partly_checked?
      items.any?(&:status_checked?) && !all_checked?
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

    def promotes_count
      promote_goods.effective.count
    end

    def generate_orders(provide_ids)
      orders = provide_ids.map do |provide_id|
        order = Order.new(
          member_organ_id: member_organ_id,
          provide_id: provide_id
        )
        order.assign_attributes attributes.slice('aim', 'payment_strategy_id', 'member_id', 'agent_id', 'client_id', 'contact_id', 'station_id', 'desk_id', 'deposit_ratio')
        order.current_cart = self

        checked_all_items.select { |i| i.provide_id.to_s == provide_id }.each do |item|
          item.order = order
          item.status = 'ordered'
        end

        order
      end

      self.class.transaction do
        orders.each(&:save!)
        compute_amount!
      end
    end

    def generate_order!
      order = Order.new(organ_id: organ_id, user_id: user_id)
      order.address_id ||= address_id if need_address?
      order.assign_attributes attributes.slice('aim', 'payment_strategy_id', 'member_id', 'agent_id', 'client_id', 'contact_id', 'station_id', 'desk_id', 'deposit_ratio')
      order.current_cart = self

      checked_all_items.each do |item|
        item.order = order
        item.status = 'ordered'
      end
      cart_promotes.each do |cart_promote|
        cart_promote.order = order
        cart_promote.status = 'ordered'
      end

      self.class.transaction do
        order.save!
        compute_amount!
      end

      order
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

    def compute_amount
      self.total_quantity = checked_items.sum(&->(i){ i.original_quantity.to_d })
      _checked_all_items = checked_all_items

      self.retail_price = _checked_all_items.sum(&->(i){ i.retail_price.to_d })
      self.discount_price = _checked_all_items.sum(&->(i){ i.discount_price.to_d })
      self.bulk_price = self.retail_price - self.discount_price

      self.item_amount = _checked_all_items.sum(&->(i){ i.amount.to_d })
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

    def init_cart_item(params, **options)
      options.with_defaults! params.permit(:good_id, :purchase_id, :provide_id, :dispatch, :produce_on, :scene_id).to_h.to_options
      options.with_defaults! dispatch: organ.dispatch if organ

      item = find_item(**options) || items.build(options)
      item.status = 'checked'
      item.assign_attributes params.permit(['station_id', 'desk_id', 'current_cart_id'] & Item.column_names)
      if item.new_record?
        item.number = params[:number].presence || 1
      elsif params[:number].present?
        item.number = params[:number]
      end
      item
    end

    def find_item(**options)
      args = attr_options(**options)
      logger.debug "\e[35m  Current Cart: #{id}, Options: #{options}, Args: #{args}  \e[0m"
      cart_items.find(&->(i){ i.attributes.slice(*args.keys) == args })
    end

    def find_items_except_provide(provide_ids, **options)
      args = attr_options(**options)
      cart_items.select { |i| i.attributes.slice(*args.keys) == args && i.provide_id && provide_ids.exclude?(i.provide_id) }
    end

    def find_items(good_ids, **options)
      options.symbolize_keys!
      args = attr_options(**options)
      cart_items.select { |i| i.attributes.slice(*args.keys) == args && good_ids.include?(i.good_id) }
    end

    def find_purchase_items(purchase_ids, **options)
      options.symbolize_keys!
      args = attr_options(**options)
      cart_items.select { |i| i.attributes.slice(*args.keys) == args && purchase_ids.include?(i.purchase_id) }
    end

    def attr_options(**options)
      options.transform_values! { |i| i.presence }
      args = { good_type: good_type, aim: aim }
      args.merge! options.slice(:good_type, :good_id, :aim, :dispatch, :contact_id, :member_id, :provide_id, :purchase_id, :scene_id)
      args.merge! produce_on: options[:produce_on].to_date if options[:produce_on].present?
      args.stringify_keys!
    end

    def sync_contact_to_items(contact)
      agent_items.each do |agent_item|
        agent_item.update(contact_id: contact.id)
      end

      maintain = agent.maintains.find_or_initialize_by(contact_id: contact.id)
      maintain.state = 'carted'
      maintain.save
    end

    def sync_original_amount
      self.original_amount = item_amount + overall_additional_amount
    end

    def migrate_from(other_cart)
      other_cart.items.each do |item|
        item.current_cart = self
        item.assign_attributes filter_hash
        item.save
      end
    end

    class_methods do

      def get_cart(params, current_cart_id: nil, **options)
        cart_id = current_cart_id || params[:current_cart_id].presence || params.dig(:item, :current_cart_id).presence
        if cart_id
          cart = find cart_id
        else
          options.with_defaults! good_type: 'Factory::Production', aim: 'use'
          options.with_defaults! params.permit(:desk_id, :station_id).to_h.to_options # 合并来自 params 的参数，转化为 symbol key
          create_options = ([:user_id, :member_id, :member_organ_id, :client_id, :contact_id, :agent_id] & column_names.map(&:to_sym)).each_with_object({}) { |i,h| h.merge! i => nil }.merge! options
          options.with_defaults! ([:agent_id, :contact_id, :client_id, :desk_id, :station_id] & column_names.map(&:to_sym)).each_with_object({}) { |i, h| h.merge! i => nil }

          cart = find_by(options) || create_or_find_by(create_options)
        end
        cart.compute_amount! unless cart.fresh
        logger.debug "\e[35m  Current Cart: #{cart.id}, Find Options: #{options}, Create Options: #{create_options}  \e[0m"
        cart
      end

    end

  end
end
