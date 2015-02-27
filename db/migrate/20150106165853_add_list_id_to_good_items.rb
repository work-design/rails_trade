class AddListIdToGoodItems < ActiveRecord::Migration
  def change
    add_column :good_items, :list_id, :integer
  end
end
