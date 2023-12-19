module Trade
  module Ext::Good
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :sku, :string, default: -> { SecureRandom.hex }
      attribute :price, :decimal, default: 0
      attribute :advance_price, :decimal, default: 0
      attribute :card_price, :json, default: {}
      attribute :wallet_price, :json, default: {}
      attribute :extra, :json, default: {}
      attribute :unit, :string
      attribute :quantity, :decimal, default: 0
      attribute :unified_quantity, :decimal, default: 0
      attribute :invest_ratio, :decimal, precision: 4, scale: 2, default: 0, comment: '抽成比例'
      attribute :good_type, :string, default: -> { base_class.name }

      has_many :items, class_name: 'Trade::Item', as: :good
      has_many :orders, through: :items, source: :trade
      has_many :addresses, -> { distinct }, class_name: 'Factory::Address', through: :items

      has_many :promote_goods, class_name: 'Trade::PromoteGood', as: :good
      has_many :unavailable_promote_goods, ->(o) { unavailable.where(good_id: [o.id, nil]) }, class_name: 'Trade::PromoteGood', primary_key: :good_type, foreign_key: :good_type
      has_many :available_promote_goods, ->(o) { available.where(good_id: [o.id, nil]) }, class_name: 'Trade::PromoteGood', primary_key: :good_type, foreign_key: :good_type
      has_many :available_promotes, class_name: 'Trade::Promote', through: :available_promote_goods, source: :promote
      has_many :default_promote_goods, ->(o) { default.where(good_id: [o.id, nil]) }, class_name: 'Trade::PromoteGood', primary_key: :good_type, foreign_key: :good_type
      has_many :wallet_goods, ->(o) { where(good_id: [o.id, nil]) }, class_name: 'Trade::WalletGood', primary_key: :good_type, foreign_key: :good_type
      has_many :wallet_templates, class_name: 'Trade::WalletTemplate', through: :wallet_goods

      has_one_attached :logo
    end

    def item_extra
      {}
    end

    def wallet_codes
      wallet_goods.pluck(:wallet_code)
    end

    def final_price
      compute_amount
      #self.retail_price + self.promote_price
    end

    def valid_promote_goods
      PromoteGood.valid.where(good_type: self.base_class_name, good_id: [nil, self.id]).where.not(promote_id: self.promote_goods.select(:promote_id).unavailable)
    end

    def generate_order!(cart: , maintain_id: nil, **params)
      o = generate_order(cart: cart, maintain_id: maintain_id, **params)
      o.check_state
      o.save!
      o
    end

    def generate_order(cart: , maintain_id: nil, **params)
      o = cart.orders.build

      o.organ_id = self.organ_id if self.respond_to?(:organ_id)
      if o.respond_to?(:maintain_id)
        o.maintain_id = maintain_id
        o.organ_id ||= o.maintain&.organ_id
      end

      ti = o.items.build(good: self)
      ti.assign_attributes params.slice(:number)

      o.assign_attributes params.slice(:extra, :currency)
      o
    end

    def wallet_exchange
      wallet_price.transform_values(&->(v){ Rational(v, price.to_s) })
    end

    def order_done(item = nil)
      logger.error "order_done Should realize in good entity, #{item.object_id}"
    end

    def order_trial(item = nil)
      logger.error 'order_trial Should realize in good entity'
    end

    def order_deliverable(item = nil)
      logger.error 'order_deliverable Should realize in good entity'
    end

    def order_rentable(item = nil)
      logger.error 'order_rentable Should realize in good entity'
    end

    def order_rented(item = nil)
      logger.error 'order_rented Should realize in good entity'
    end

    def order_refund(item = nil)
      logger.error 'order_refund Should realize in good entity'
    end

    def order_prune(item = nil)
      logger.error 'order_prune Should realize in good entity'
    end

  end
end
