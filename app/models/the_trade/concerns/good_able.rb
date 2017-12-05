module GoodAble
  extend ActiveSupport::Concern

  included do
    has_many :cart_items, as: :good, dependent: :destroy
    has_many :order_items, as: :good, dependent: :nullify
    has_many :orders, through: :order_items
    has_many :good_serves, as: :good, dependent: :destroy

    composed_of :serve,
                class_name: 'ServeFee',
                mapping: ['id', 'good_id'],
                constructor: Proc.new { |id| ServeFee.new(self.name, id) }
    composed_of :promote,
                class_name: 'PromoteFee',
                mapping: [['id', 'good_id']],
                constructor: Proc.new { |id| PromoteFee.new(self.name, id) }
  end

  def for_select_serves
    @for_sales = Serve.for_sale.where.not(id: good_serves.map(&:serve_id).uniq)
    @for_sales.map do |serve|
      self.serve.get_charge(serve)
    end
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

  def generate_order(buyer, params)
    oi = self.order_items.build
    oi.quantity = params[:quantity]
    if params[:amount]
      oi.amount = params[:amount]
    else
      oi.amount = oi.quantity * self.price.to_d
    end

    o = oi.build_order
    o.buyer = buyer
    o.subtotal = oi.amount
    o.amount = oi.amount
    o.currency = self.currency
    o.payment_status = 'unpaid'

    self.class.transaction do
      o.save!
      oi.save!
    end
    o
  end

end

# required attributes

# sku
# price


# t.integer  "provider_id", limit: 4
# t.string   "sku",         limit: 255
# t.float    "price",       limit: 24,    default: 9999.0
# t.integer  "sales_count", limit: 4,     default: 0
# t.boolean  "published",   limit: 1,     default: true
# t.integer  "promote_id",  limit: 4
