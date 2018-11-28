module RailsTradeGood
  extend ActiveSupport::Concern

  included do
    attribute :name, :string
    attribute :sku, :string, default: -> { SecureRandom.hex }
    attribute :price, :decimal, default: 0
    attribute :currency, :string
    attribute :advance_payment, :decimal, default: 0

    has_many :cart_items, as: :good, autosave: true, dependent: :destroy

    has_many :order_items, as: :good, dependent: :nullify
    has_many :orders, through: :order_items

    has_many :promote_goods, as: :good
    has_many :promotes, through: :promote_goods

    composed_of :serve,
                class_name: 'ServeFee',
                mapping: ['id', 'good_id'],
                constructor: Proc.new { |id| ServeFee.new(self.name, id, 1, nil, nil, self.extra) }
    composed_of :promote,
                class_name: 'PromoteFee',
                mapping: [['id', 'good_id']],
                constructor: Proc.new { |id| PromoteFee.new(self.name, id) }

    def self.extra
      {}
    end
  end

  def extra
    {}
  end

  def retail_price
    self.price.to_d + self.serve.subtotal
  end

  def final_price
    self.retail_price + self.promote.subtotal
  end

  def order_done
    puts 'Should realize in good entity'
  end

  def all_serves
    Serve.default_where('serve_goods.good_type': self.class.name, 'serve_goods.good_id': [nil, self.id])
  end

  def all_promotes
    Promote.default_where('promote_goods.good_type': self.class.name, 'promote_goods.good_id': [nil, self.id])
  end

  def generate_order!(buyer, params = {})
    o = generate_order(buyer, params)
    o.check_state
    o.save!
    o
  end

  def generate_order(buyer, params = {})
    o = buyer.orders.build
    o.currency = self.currency

    oi = o.order_items.build
    oi.good = self
    if params[:number].to_i > 0
      oi.number = params.delete(:number)
    else
      oi.number = 1
    end

    if params[:amount]
      oi.amount = params.delete(:amount)
    else
      oi.amount = oi.number * self.price.to_d
    end

    o.assign_attributes params
    o.amount = oi.amount
    o
  end

end
