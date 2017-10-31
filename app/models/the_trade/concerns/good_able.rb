module GoodAble
  extend ActiveSupport::Concern

  included do
    has_many :cart_items, as: :good, dependent: :destroy
    has_many :order_items, as: :good, dependent: :nullify
    has_many :orders, through: :order_items
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
