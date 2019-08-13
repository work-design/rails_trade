class RailsTradeInit < ActiveRecord::Migration[5.2]
  def change

    create_table :carts do |t|
      t.references :user
      t.references :buyer, polymorphic: true
      t.references :organ  # For SaaS
      t.references :payment_strategy
      t.string :session_id, limit: 128
      t.decimal :amount, precision: 10, scale: 2
      t.integer :deposit_ratio
      t.boolean :default
      t.integer :trade_items_count, default: 0
      t.timestamps
    end

    create_table :orders do |t|
      t.references :organ  # For SaaS
      t.references :cart
      t.references :buyer, polymorphic: true
      t.references :payment_strategy
      t.string :uuid
      t.string :state
      t.decimal :item_amount, precision: 10, scale: 2
      t.decimal :overall_additional_amount, precision: 10, scale: 2
      t.decimal :overall_reduced_amount, precision: 10, scale: 2
      t.decimal :amount, precision: 10, scale: 2
      t.decimal :received_amount, precision: 10, scale: 2
      t.string :currency
      t.integer :payment_id
      t.string :payment_status, index: true
      t.boolean :myself
      t.string :note, limit: 4096
      t.datetime :expire_at
      t.integer :lock_version
      t.timestamps
    end

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

    create_table :payment_strategies do |t|
      t.string :name
      t.string :strategy
      t.integer :period, default: 0
      t.timestamps
    end

  end
end
