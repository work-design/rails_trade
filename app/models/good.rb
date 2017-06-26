class Good < ApplicationRecord
  #belongs_to :provider, optional: true
  belongs_to :promote, optional: true

  has_many :cart_products
  has_many :sales

  has_many :good_items, dependent: :destroy
  has_many :items, :through => :good_items
  has_many :lists, :through => :items

  has_many :good_produces, dependent: :destroy

  validates :sku, presence: true

  def same_provider
    self.class.where(provider_id: self.provider_id)
  end

end


# t.integer  "provider_id", limit: 4
# t.string   "sku",         limit: 255
# t.float    "price",       limit: 24,    default: 9999.0
# t.integer  "sales_count", limit: 4,     default: 0
# t.boolean  "published",   limit: 1,     default: true
# t.integer  "promote_id",  limit: 4

