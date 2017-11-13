class CreatePaymentStrategies < ActiveRecord::Migration[5.1]
  def change

    create_table :payment_strategies do |t|
      t.string :name
      t.string :strategy
      t.integer :period, default: 0
      t.timestamps
    end

    create_table :promotes do |t|
      t.string :type
      t.string :unit
      t.string :name
      t.datetime :start_at
      t.datetime :finish_at
      t.boolean :verified, default: false
      t.timestamps
    end

    create_table :charges do |t|
      t.refereneces :promote
      t.string :unit
      t.decimal :min, precision: 10, scale: 2
      t.decimal :max, precision: 10, scale: 2
      t.decimal :price, precision: 10, scale: 2
      t.string :type
      t.timestamps
    end

  end
end
