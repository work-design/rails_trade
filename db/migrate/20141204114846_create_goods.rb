class CreateGoods < ActiveRecord::Migration
  def change

    create_table "goods", force: true do |t|
      t.string   "name"
      t.string   "logo"
      t.text     "overview"
      t.integer  "provider_id"
      t.string   "sku"

      t.float    "price", default: 9999.0
      t.float    "price_lower", default: 9999.0
      t.float  :price_higher, default: 9999.0
      t.integer  "sales_count", default: 0

      t.boolean  "published", default: true

      # 促销状态
      t.integer  "promote_id"
      t.datetime "start_at"
      t.datetime "finish_at"

      t.datetime "created_at",                               null: false
      t.datetime "updated_at",                               null: false
    end

    create_table "good_items", force: true do |t|
      t.integer "good_id"
      t.integer "item_id"
      t.string  "picture"
    end

    create_table "promotes", force: true do |t|
      t.string "name"
      t.integer :price_reduce
    end

    create_table "providers", force: true do |t|
      t.string   "name"
      t.string   "logo"
      t.string   "address"
      t.integer  "area_id"
      t.datetime "created_at",              null: false
      t.datetime "updated_at",              null: false
    end

    create_table "good_partners", force: true do |t|
      t.integer "good_id"
      t.integer "partner_id"
    end



  end
end
