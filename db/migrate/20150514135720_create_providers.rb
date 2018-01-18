class CreateProviders < ActiveRecord::Migration[5.1]
  def change

    create_table :providers do |t|
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

    create_table :cart_items do |t|
      t.references :user
      t.references :buyer
      t.references :good, polymorphic: true
      t.string :session_id, limit: 128
      t.string :status
      t.integer :quantity
      t.string :extra, limit: 1024
      t.boolean :checked, default: false
      t.boolean :myself
      t.boolean :archived, default: false
      t.timestamps
    end

    create_table :areas do |t|
      t.string :nation, default: ''
      t.string :province, default: ''
      t.string :city, default: ''
      t.string :district, default: ''
      t.boolean :published, default: true
      t.boolean :popular, default: false
      t.timestamps
    end

    create_table :addresses do |t|
      t.references :area
      t.references :user
      t.references :buyer
      t.string :kind
      t.timestamps
    end

  end
end
