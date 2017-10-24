class CreateProviders < ActiveRecord::Migration[5.1]
  def change

    create_table :providers do |t|
      t.references :user
      t.references :area
      t.string :type
      t.string :name
      t.string :service_tel
      t.string :service_qq
      t.string :address
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
