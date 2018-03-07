class CreatePaymentReferences < ActiveRecord::Migration[5.1]
  def change
    
    create_table :payment_references do |t|
      t.references :payment_method
      t.references :buyer
      t.references :user
      t.timestamps
    end
    
  end
end
