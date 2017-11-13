class CreatePaymentReferences < ActiveRecord::Migration[5.1]
  def change
    create_table :payment_references do |t|
      t.references :payment_method
      t.references :buyer
      t.timestamps
    end


  end
end
