module GoodAble
  extend ActiveSupport::Concern

  included do
    has_many :cart_items, as: :good, dependent: :nullify
    has_many :order_items, as: :good, dependent: :nullify
  end


  def generate_order(buyer, params)
    oi = self.order_items.build
    oi.number = params[:number]
    if params[:amount]
      oi.amount = params[:amount]
    else
      oi.amount = oi.number * self.price
    end

    o = oi.build_order
    o.buyer = buyer

    self.class.transaction do
      o.save!
      oi.save!
    end
    o
  end

  def compute_fee
    if number.blank? && self.unit.present?
      self.number = (self.quantity.to_f / good.quantity.to_f).ceil
    end

    if self.unit
      self.amount = Charge.price(quantity, self.unit)
    else
      self.amount = self.number * good.price
    end
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
