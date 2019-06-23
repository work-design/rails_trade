class RailsTradeDbOrder < ActiveRecord::Migration[5.2]
  def change

    create_table :orders do |t|
      t.references :user
      t.references :cart
      t.references :buyer, polymorphic: true
      t.references :payment_strategy
      t.string :uuid, null: false
      t.string :state
      t.decimal :item_sum, precision: 10, scale: 2
      t.decimal :overall_promote_sum, precision: 10, scale: 2
      t.decimal :adjust_amount, precision: 10, scale: 2
      t.decimal :amount, precision: 10, scale: 2
      t.decimal :received_amount, precision: 10, scale: 2
      t.string :currency
      t.integer :payment_id
      t.string :payment_type
      t.string :payment_status, index: true
      t.boolean :myself
      t.string :note, limit: 4096
      t.datetime :expire_at
      t.timestamps
    end

    create_table :order_items do |t|
      t.references :order
      t.references :cart_item
      t.references :good, polymorphic: true
      t.integer :number
      t.decimal :quantity, precision: 10, scale: 2 # 用来表示重量
      t.decimal :good_sum, precision: 10, scale: 2
      t.decimal :promote_sum, precision: 10, scale: 2
      t.decimal :amount, precision: 10, scale: 2
      t.string :good_name
      t.timestamps
      if connection.adapter_name == 'PostgreSQL'
        t.jsonb :extra
      else
        t.json :extra
      end
    end

  end
end
