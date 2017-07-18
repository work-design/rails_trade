class CreatePaymentStrategies < ActiveRecord::Migration[5.1]
  def change
    create_table :payment_strategies do |t|

      t.timestamps
    end
  end
end
