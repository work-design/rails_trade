class RailsTradeDbPromotes < ActiveRecord::Migration[5.1]
  def change

    create_table :promotes do |t|
      t.references :deal, polymorphic: true
      t.string :name
      t.string :short_name
      t.string :code
      t.string :description
      t.datetime :start_at
      t.datetime :finish_at
      t.string :scope
      t.boolean :verified
      t.boolean :default
      t.integer :sequence
      t.timestamps
    end

    create_table :promote_charges do |t|
      t.references :promote
      t.decimal :min, precision: 10, scale: 2, default: 0
      t.decimal :max, precision: 10, scale: 2, default: 99999999.99
      t.boolean :contain_min
      t.boolean :contain_max
      t.decimal :parameter, precision: 10, scale: 2
      t.decimal :base_price, precision: 10, scale: 2
      t.string :type
      t.string :metering
      t.string :unit
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

    create_table :entity_promotes do |t|
      t.references :entity, polymorphic: true
      t.references :item, polymorphic: true
      t.references :promote
      t.references :promote_charge
      t.references :promote_good
      t.references :promote_buyer
      t.string :scope
      t.integer :sequence
      t.decimal :based_amount, precision: 10, scale: 2
      t.decimal :amount, precision: 10, scale: 2
      t.decimal :original_amount, precision: 10, scale: 2
      t.timestamps
    end

  end
end
