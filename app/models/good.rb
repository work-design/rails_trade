class Good < ApplicationRecord
  belongs_to :promote, optional: true

  has_many :sales
  has_many :cart_products, dependent: :destroy
  has_many :good_produces, dependent: :destroy

  validates :sku, presence: true, uniqueness: true

  before_save :sync_name

  def same_provider
    self.class.where(provider_id: self.provider_id)
  end

  def sync_name
    self.name = entity.name
  end
end


# t.integer  "provider_id", limit: 4
# t.string   "sku",         limit: 255
# t.float    "price",       limit: 24,    default: 9999.0
# t.integer  "sales_count", limit: 4,     default: 0
# t.boolean  "published",   limit: 1,     default: true
# t.integer  "promote_id",  limit: 4

