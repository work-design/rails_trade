class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.string :uuid, null: false
      t.integer :state, default: 0
      t.decimal :amount, precision: 10, scale: 2
      t.decimal :received_amount, precision: 10, scale: 2
      t.decimal :subtotal, precision: 10, scale: 2
      t.decimal :shipping_fee, precision: 10, scale: 2
      t.decimal :handling_fee, precision: 10, scale: 2
      t.string :currency
      t.references :buyer
      t.integer :payment_id
      t.integer :payment_status
      t.timestamps
    end
  end
end