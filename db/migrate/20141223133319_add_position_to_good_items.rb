class AddPositionToGoodItems < ActiveRecord::Migration
  def change
    add_column :good_items, :position, :integer, default: 0
  end
end
