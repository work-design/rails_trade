class RailsTradeInit < ActiveRecord::Migration[5.2]
  def change

    create_table :trade_items do |t|
      t.references :trade, polymorphic: true
      t.references :good, polymorphic: true
      t.string :status
      t.integer :number
      t.decimal :weight, precision: 10, scale: 2 # 用来表示重量
      t.decimal :single_price, precision: 10, scale: 2
      t.decimal :original_amount, precision: 10, scale: 2
      t.decimal :additional_amount, precision: 10, scale: 2
      t.decimal :reduced_amount, precision: 10, scale: 2
      t.decimal :retail_price, precision: 10, scale: 2
      t.decimal :wholesale_price, precision: 10, scale: 2
      t.decimal :amount, precision: 10, scale: 2
      t.string :good_name
      t.boolean :myself
      t.boolean :starred  # 是否收藏
      if connection.adapter_name == 'PostgreSQL'
        t.jsonb :extra
      else
        t.json :extra
      end
      t.timestamps
    end
    

  end
end
