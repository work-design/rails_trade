class RailsTradePromotes < ActiveRecord::Migration[5.1]
  def change

    create_table :promotes do |t|
      t.string :type
      t.string :unit
      t.string :name
      t.datetime :start_at
      t.datetime :finish_at
      t.string :scope
      t.boolean :verified, default: false
      t.boolean :overall, default: false
      t.boolean :contain_max, default: false
      t.integer :sequence, default: 1
      t.timestamps
    end

    create_table :promote_charges do |t|
      t.references :promote
      t.decimal :min, precision: 10, scale: 2, default: 0
      t.decimal :max, precision: 10, scale: 2, default: 99999999.99
      t.decimal :price, precision: 10, scale: 2
      t.string :type
      t.timestamps
    end

    create_table :order_promotes do |t|
      t.references :order, null: false
      t.references :order_item
      t.references :promote
      t.references :promote_charge
      t.decimal :amount, precision: 10, scale: 2
      t.timestamps
    end

    create_table :promote_buyers do |t|
      t.references :buyer
      t.references :promote
      t.timestamps
    end

    create_table :promote_goods do |t|
      t.references :good, polymorphic: true
      t.references :promote
      t.timestamps
    end

  end
end
