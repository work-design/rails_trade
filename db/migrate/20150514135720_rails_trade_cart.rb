class RailsTradeCart < ActiveRecord::Migration[5.2]
  def change

    create_table :carts do |t|
      t.references :buyer, polymorphic: true
      t.string :session_id, limit: 128
      t.timestamp
    end

    create_table :cart_items do |t|
      t.references :buyer, polymorphic: true
      t.references :good, polymorphic: true
      t.string :session_id, limit: 128
      t.string :status
      t.integer :number
      t.boolean :checked, default: false
      t.boolean :myself
      t.boolean :archived, default: false
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
      t.string :scope
      t.decimal :price, precision: 10, scale: 2
      t.timestamps
    end

    create_table :cart_promotes do |t|
      t.references :cart
      t.references :cart_item
      t.references :promote
      t.string :scope
      t.decimal :price, precision: 10, scale: 2
      t.timestamps
    end

  end
end
