class CreatePays < ActiveRecord::Migration
  def change

    create_table "orders", force: true do |t|
      t.integer  "user_id",            null: false
      t.integer  "good_id"
      t.float :price
      t.integer  "quantity",    default: 1
      t.float    "total_price"
      t.time     "order_at"
      t.date     "order_on"
      t.datetime "created_at",                         null: false
      t.datetime "updated_at", null: false
    end

    create_table :payments do |t|
      t.integer :user_id
      t.integer :order_id
      t.float :total_price
    end

    create_table :shipments do |t|
      t.integer :user_id
      t.integer :area_id
      t.string :address
    end

    create_table :order_shipments do |t|
      t.integer :order_id
      t.integer :shipment_id
    end

  end
end
