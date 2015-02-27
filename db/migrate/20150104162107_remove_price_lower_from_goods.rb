class RemovePriceLowerFromGoods < ActiveRecord::Migration
  def change
    remove_columns :goods, :price_higher, :price_lower
  end
end
