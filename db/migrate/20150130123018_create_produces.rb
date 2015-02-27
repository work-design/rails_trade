class CreateProduces < ActiveRecord::Migration
  def change
    create_table :produces do |t|
      t.string :product
      t.string :name
      t.text :content
      t.datetime :start_at
      t.datetime :finish_at

      t.timestamps
    end

    create_table :good_produces do |t|
      t.integer :good_id
      t.integer :produce_id
      t.string :picture
      t.integer :position, default: 0
      t.datetime :start_at
      t.datetime :finish_at
    end
  end
end
