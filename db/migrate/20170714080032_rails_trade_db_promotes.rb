class RailsTradeDbPromotes < ActiveRecord::Migration[5.1]
  def change

    create_table :promotes do |t|
      t.references :deal, polymorphic: true
      t.string :type
      t.string :name
      t.string :short_name
      t.string :code
      t.string :description
      t.datetime :start_at
      t.datetime :finish_at
      t.string :scope
      t.string :extra, array: true
      t.boolean :verified, default: false
      t.boolean :contain_max, default: false
      t.boolean :default, default: false
      t.integer :sequence, default: 1
      t.string :unit
      t.timestamps
    end

    create_table :promote_charges do |t|
      t.references :promote
      t.decimal :min, precision: 10, scale: 2, default: 0
      t.decimal :max, precision: 10, scale: 2, default: 99999999.99
      t.decimal :parameter, precision: 10, scale: 2
      t.decimal :base_price, precision: 10, scale: 2
      t.string :type
      t.timestamps
    end
    
    create_table :promote_buyers do |t|
      t.references :buyer, polymorphic: true
      t.references :promote
      t.boolean :available
      t.string :state
      t.integer :order_promotes_count, default: 0
      t.timestamps
    end

    create_table :promote_goods do |t|
      t.references :good, polymorphic: true
      t.references :promote
      t.boolean :available
      t.timestamps
    end

    create_table :order_promotes do |t|
      t.references :order
      t.references :order_item
      t.references :promote
      t.references :promote_charge
      t.references :promote_good
      t.references :promote_buyer
      t.decimal :amount, precision: 10, scale: 2
      t.timestamps
    end

  end
end
