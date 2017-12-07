class CreatePromoteBuyers < ActiveRecord::Migration[5.1]
  def change
    create_table :promote_buyers do |t|
      t.references :buyer
      t.references :promote
      t.timestamps
    end

    create_table :promote_goods do |t|
      t.references :good, polymorphic: true
      t.references :promote
      t.timestamps
    end

    create_table :cart_item_serves do |t|
      t.references :cart_item
      t.references :serve
      t.decimal :price, precision: 10, scale: 2
      t.timestamps
    end
  end
end
