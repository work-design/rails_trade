class CreatePaymentStrategies < ActiveRecord::Migration[5.1]
  def change
    create_table :payment_strategies do |t|
      t.string :name
      t.string :strategy
      t.integer :period, default: 0
      t.timestamps
    end
  end
end
