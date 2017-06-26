class CreatePaymentReferences < ActiveRecord::Migration[5.1]
  def change
    create_table :payment_references do |t|
      t.references :payment_method
      t.references :buyer
      t.timestamps
    end

    create_table :goods do |t|
      t.string :sku, index: true
      t.string :name
      t.decimal :quantity
      t.string :unit
      t.decimal :price
      t.integer :sales_count
      t.boolean :published, default: true
      t.references :promote
      t.timestamps
    end

    create_table :charges do |t|
      t.string :unit
      t.decimal :min
      t.decimal :max
      t.decimal :price
      t.string :type
      t.timestamps
    end
  end
end
