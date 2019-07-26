class RailsTradePromotes < ActiveRecord::Migration[5.1]
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
      t.string :metering
      t.integer :sequence
      t.boolean :verified
      t.booleam :editable
      t.timestamps
    end

    create_table :promote_charges do |t|
      t.references :promote
      t.decimal :min, precision: 10, scale: 2, default: 0
      t.decimal :max, precision: 10, scale: 2, default: 99999999.99
      t.decimal :filter_min, precision: 10, scale: 2
      t.decimal :filter_max, precision: 10, scale: 2
      t.boolean :contain_min
      t.boolean :contain_max
      t.decimal :parameter, precision: 10, scale: 2
      t.decimal :base_price, precision: 10, scale: 2
      t.string :type
      t.string :unit
      t.timestamps
    end

    create_table :promote_goods do |t|
      t.references :promote
      t.references :good, polymorphic: true
      t.string :status
      t.timestamps
    end
    
    create_table :promote_buyers do |t|
      t.references :promote
      t.references :promote_good
      t.references :buyer, polymorphic: true
      t.string :state
      t.integer :trade_promotes_count, default: 0
      t.datetime :effect_at
      t.datetime :expire_at
      t.timestamps
    end
    
    create_table :trade_promotes do |t|
      t.references :trade, polymorphic: true
      t.references :trade_item
      t.references :promote
      t.references :promote_charge
      t.references :promote_good
      t.references :promote_buyer
      t.string :scope
      t.integer :sequence
      t.decimal :based_amount, precision: 10, scale: 2
      t.decimal :original_amount, precision: 10, scale: 2
      t.decimal :computed_amount, precision: 10, scale: 2
      t.decimal :amount, precision: 10, scale: 2
      t.string :note
      t.timestamps
    end

  end
end
