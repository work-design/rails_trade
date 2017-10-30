class CreatePaymentStrategies < ActiveRecord::Migration[5.1]
  def change

    create_table :payment_strategies do |t|
      t.string :name
      t.string :strategy
      t.integer :period, default: 0
      t.timestamps
    end

    create_table :promotes do |t|
      t.string :code
      t.string :name
      t.integer :scope, default: 0
      t.datetime :start_at
      t.datetime :finish_at
      t.timestamps
    end

  end
end
