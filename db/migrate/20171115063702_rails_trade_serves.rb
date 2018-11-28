class RailsTradeServes < ActiveRecord::Migration[5.1]
  def change

    create_table :serves do |t|
      t.string :type
      t.string :unit
      t.string :name
      t.string :scope
      t.string :extra
      t.boolean :verified, default: false
      t.boolean :overall, default: true
      t.boolean :contain_max, default: false
      t.boolean :default, default: false
      t.references :deal, polymorphic: true
      t.timestamps
    end

    create_table :serve_charges do |t|
      t.references :serve
      t.decimal :min, precision: 10, scale: 2, default: 0
      t.decimal :max, precision: 10, scale: 2, default: 99999999.99
      t.decimal :parameter, precision: 10, scale: 2
      t.decimal :base_price, precision: 10, scale: 2, default: 0
      t.string :type
      t.timestamps
    end

    create_table :order_serves do |t|
      t.references :order, null: false
      t.references :order_item
      t.references :serve
      t.references :serve_charge
      t.decimal :amount, precision: 10, scale: 2
      t.timestamps
    end

    create_table :serve_goods do |t|
      t.references :good, polymorphic: true
      t.references :serve
      t.timestamps
    end

    create_table :cart_item_serves do |t|
      t.references :cart_item
      t.references :serve
      t.string :scope
      t.decimal :price, precision: 10, scale: 2
      t.timestamps
    end

  end
end
