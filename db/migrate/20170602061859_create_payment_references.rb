class CreatePaymentReferences < ActiveRecord::Migration[5.1]
  def change
    create_table :payment_references do |t|
      t.references :payment_method
      t.references :buyer
      t.timestamps
    end

    create_table :charges do |t|
      t.string :unit
      t.decimal :min, precision: 10, scale: 2
      t.decimal :max, precision: 10, scale: 2
      t.decimal :price, precision: 10, scale: 2
      t.string :type
      t.timestamps
    end
  end
end
