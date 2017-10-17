class CreateProviders < ActiveRecord::Migration[5.1]
  def change

    create_table :providers do |t|
      t.string   "name",        limit: 255
      t.string   "logo_url",        limit: 255
      t.integer  "area_id"
      t.string   "address",     limit: 255
      t.string   "service_tel", limit: 255
      t.string   "service_qq",  limit: 255
      t.timestamps
    end

    create_table :goods do |t|
      t.string :sku, index: true
      t.string :name
      t.decimal :quantity
      t.string :unit
      t.decimal :price
      t.integer :sales_count
      t.boolean :published, default: true
      t.references :promote
      t.timestamps
    end

  end
end
