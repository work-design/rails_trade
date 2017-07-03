module GoodAble
  extend ActiveSupport::Concern

  included do
    belongs_to :promote, optional: true

    has_many :cart_items, dependent: :nullify
    has_many :order_items, dependent: :nullify

    OrderItem.belongs_to :good, class_name: name, foreign_key: :good_id
    CartItem.belongs_to :good, class_name: name, foreign_key: :good_id
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
