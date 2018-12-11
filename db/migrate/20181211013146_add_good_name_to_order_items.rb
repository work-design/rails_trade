class AddGoodNameToOrderItems < ActiveRecord::Migration[5.2]
  def change
    add_column :order_items, :good_name, :string
  end
end
