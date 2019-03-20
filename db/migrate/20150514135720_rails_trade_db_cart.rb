class RailsTradeDbCart < ActiveRecord::Migration[5.2]
  def change

    create_table :carts do |t|
      t.references :buyer, polymorphic: true
      t.string :session_id, limit: 128
      t.decimal :amount, precision: 10, scale: 2
      t.timestamp
    end

    create_table :cart_items do |t|
      t.references :buyer, polymorphic: true
      t.references :good, polymorphic: true
      t.string :session_id, limit: 128
      t.string :status
      t.boolean :checked, default: false
      t.boolean :myself
      t.boolean :archived, default: false
      t.integer :number
      t.decimal :price, precision: 10, scale: 2
      t.decimal :amount, precision: 10, scale: 2
      if connection.adapter_name == 'PostgreSQL'
        t.jsonb :extra
      else
        t.json :extra
      end
      t.timestamps
    end

    create_table :cart_serves do |t|
      t.references :cart
      t.references :cart_item
      t.references :serve
      t.references :serve_charge
      t.decimal :original_amount, precision: 10, scale: 2
      t.decimal :amount, precision: 10, scale: 2
      t.string :state
      t.timestamps
    end

    create_table :cart_promotes do |t|
      t.references :cart
      t.references :cart_item
      t.references :promote
      t.references :promote_charge
      t.references :promote_buyer
      t.decimal :amount, precision: 10, scale: 2
      t.string :state
      t.timestamps
    end

  end
end
