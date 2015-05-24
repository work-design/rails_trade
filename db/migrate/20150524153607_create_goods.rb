class CreateGoods < ActiveRecord::Migration
  def change
    create_table "goods", force: :cascade do |t|
      t.string   "name",        limit: 255
      t.string   "logo_url",        limit: 255
      t.text     "overview",    limit: 65535
      t.integer  "provider_id", limit: 4
      t.string   "sku",         limit: 255
      t.float    "price",       limit: 24,    default: 9999.0
      t.integer  "sales_count", limit: 4,     default: 0
      t.boolean  "published",   limit: 1,     default: true
      t.integer  "promote_id",  limit: 4
      t.timestamps
    end
  end
end
