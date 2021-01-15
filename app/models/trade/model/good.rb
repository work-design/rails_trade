module RailsTrade::Good
  extend ActiveSupport::Concern

  included do
    attribute :name, :string
    attribute :sku, :string, default: -> { SecureRandom.hex }
    attribute :price, :decimal, precision: 10, scale: 2, default: 0
    attribute :advance_price, :decimal, default: 0
    attribute :extra, :json, default: {}
    attribute :unit, :string
    attribute :quantity, :decimal, default: 0
    attribute :unified_quantity, :decimal, default: 0

    has_many :trade_items, as: :good, autosave: true, dependent: :destroy
    has_many :orders, through: :trade_items, source: :trade
    has_many :addresses, -> { distinct }, through: :trade_items

    has_many :promote_goods, as: :good
  end

  def final_price
    compute_amount
    #self.retail_price + self.promote_price
  end

  def valid_promote_goods
    PromoteGood.valid.where(good_type: self.class.base_class.name, good_id: [nil, self.id]).where.not(promote_id: self.promote_goods.select(:promote_id).unavailable)
  end

  def default_promote_goods
    PromoteGood.default.where(good_type: self.class.base_class.name, good_id: [nil, self.id])
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

  def order_paid(trade_item = nil)
  end

end
