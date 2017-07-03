module GoodAble
  extend ActiveSupport::Concern

  included do
    has_many :cart_items, as: :good, dependent: :nullify
    has_many :order_items, as: :good, dependent: :nullify

    OrderItem.belongs_to :good, polymorphic: true
    CartItem.belongs_to :good, polymorphic: true
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
