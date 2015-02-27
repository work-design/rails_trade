class MoveStartAtToPromiton < ActiveRecord::Migration
  def change
    add_column :promotes, :start_at, :datetime
    add_column :promotes, :finish_at, :datetime

    remove_columns :goods, :start_at, :finish_at
  end
end
