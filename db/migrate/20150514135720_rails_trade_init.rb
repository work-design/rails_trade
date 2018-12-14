class CreateProviders < ActiveRecord::Migration[5.1]
  def change

    create_table :orders do |t|
      t.references :buyer, polymorphic: true
      t.references :payment_strategy
      t.string :uuid, null: false
      t.integer :state, default: 0
      t.decimal :amount, precision: 10, scale: 2
      t.decimal :adjust_amount, precision: 10, scale: 2
      t.decimal :received_amount, precision: 10, scale: 2, default: 0
      t.decimal :subtotal, precision: 10, scale: 2
      t.decimal :pure_serve_sum, precision: 10, scale: 2
      t.decimal :pure_promote_sum, precision: 10, scale: 2
      t.string :currency
      t.integer :payment_id
      t.string :payment_type
      t.string :payment_status, index: true
      t.boolean :myself
      t.string :note, limit: 4096
      t.string :adjust_comment
      t.timestamps
    end

    create_table :order_items do |t|
      t.references :order
      t.references :cart_item
      t.references :good, polymorphic: true
      t.integer :number
      t.decimal :quantity, precision: 10, scale: 2 # 用来表示重量
      t.decimal :pure_price, precision: 10, scale: 2
      t.decimal :promote_sum, precision: 10, scale: 2
      t.decimal :serve_sum, precision: 10, scale: 2
      t.decimal :amount, precision: 10, scale: 2
      t.jsonb :extra
      t.timestamps
    end

    create_table :cart_items do |t|
      t.references :buyer, polymorphic: true
      t.references :good, polymorphic: true
      t.string :session_id, limit: 128
      t.string :status
      t.integer :number
      t.string :extra, limit: 1024
      #t.jsonb :extra
      t.boolean :checked, default: false
      t.boolean :myself
      t.boolean :archived, default: false
      t.timestamps
    end

    create_table :payment_strategies do |t|
      t.string :name
      t.string :strategy
      t.integer :period, default: 0
      t.timestamps
    end

    create_table :areas do |t|
      t.string :nation, default: ''
      t.string :province, default: ''
      t.string :city, default: ''
      t.string :district, default: ''
      t.boolean :published, default: true
      t.boolean :popular, default: false
      t.timestamps
    end

    create_table :addresses do |t|
      t.references :area
      t.references :buyer, polymorphic: true
      t.string :kind
      t.timestamps
    end

    create_table :shipments do |t|
      t.references :buyer, polymorphic: true
      t.references :address
    end

  end
end
