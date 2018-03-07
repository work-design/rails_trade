class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    
    create_table :orders do |t|
      t.references :user
      t.references :buyer
      t.string :uuid, null: false
      t.integer :state, default: 0
      t.decimal :amount, precision: 10, scale: 2
      t.decimal :received_amount, precision: 10, scale: 2, default: 0
      t.decimal :subtotal, precision: 10, scale: 2
      t.decimal :pure_serve_sum, precision: 10, scale: 2
      t.decimal :pure_promote_sum, precision: 10, scale: 2
      t.decimal :serve_sum, precision: 10, scale: 2
      t.decimal :promote_sum, precision: 10, scale: 2
      t.string :currency
      t.integer :payment_id
      t.string :payment_type
      t.integer :payment_status
      t.boolean :myself
      t.timestamps
    end

    create_table :order_items do |t|
      t.references :order
      t.references :cart_item
      t.references :good, polymorphic: true
      t.integer :quantity
      t.decimal :pure_price, precision: 10, scale: 2
      t.decimal :promote_sum, precision: 10, scale: 2
      t.decimal :serve_sum, precision: 10, scale: 2
      t.decimal :amount, precision: 10, scale: 2
      t.timestamps
    end

    create_table :refunds do |t|
      t.references :order
      t.references :payment
      t.references :operator
      t.string :type
      t.decimal :total_amount, precision: 10, scale: 2
      t.string :buyer_identifier
      t.string :comment, limit: 512
      t.integer :state, default: 0
      t.datetime :refunded_at
      t.string :reason, limit: 512
      t.string :currency
      t.string :refund_uuid
      t.timestamps
    end

  end
end