module Trade
  module Model::Good
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :sku, :string, default: -> { SecureRandom.hex }
      attribute :price, :decimal, precision: 10, scale: 2, default: 0
      attribute :advance_price, :decimal, default: 0
      attribute :vip_price, :json, default: {}
      attribute :extra, :json, default: {}
      attribute :unit, :string
      attribute :quantity, :decimal, default: 0
      attribute :unified_quantity, :decimal, default: 0
      attribute :good_type, :string, default: -> { base_class.name }

      has_many :trade_items, class_name: 'Trade::TradeItem', as: :good, autosave: true
      has_many :orders, through: :trade_items, source: :trade
      has_many :addresses, -> { distinct }, class_name: 'Factory::Address', through: :trade_items

      has_many :promote_goods, class_name: 'Trade::PromoteGood', as: :good
      has_many :unavailable_promote_goods, ->(o) { unavailable.where(good_id: [o.id, nil]) }, class_name: 'Trade::PromoteGood', foreign_key: :good_type, primary_key: :good_type
      has_many :available_promote_goods, ->(o) { available.where(good_id: [o.id, nil]) }, class_name: 'Trade::PromoteGood', foreign_key: :good_type, primary_key: :good_type
      has_many :default_promote_goods, ->(o) { default.where(good_id: [o.id, nil]) }, class_name: 'Trade::PromoteGood', foreign_key: :good_type, primary_key: :good_type
    end

    def final_price
      compute_amount
      #self.retail_price + self.promote_price
    end

    def valid_promote_goods
      PromoteGood.valid.where(good_type: self.class.base_class.name, good_id: [nil, self.id]).where.not(promote_id: self.promote_goods.select(:promote_id).unavailable)
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

      ti = o.trade_items.build(good: self)
      ti.assign_attributes params.slice(:number)

      o.assign_attributes params.slice(:extra, :currency)
      o
    end

    def order_done(trade_item = nil)
      puts 'Should realize in good entity'
    end

    def order_trial(trade_item = nil)
    end

    def order_paid(trade_item = nil)
    end

    def order_prune(trade_item = nil)
    end

  end
end
