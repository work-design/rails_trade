class Order < ActiveRecord::Base

  belongs_to :good
  belongs_to :user


end

=begin

create_table "orders", force: :cascade do |t|
  t.integer  "user_id",     limit: 4,              null: false
  t.integer  "good_id",     limit: 4
  t.float    "price",       limit: 24
  t.integer  "quantity",    limit: 4,  default: 1
  t.float    "total_price", limit: 24
  t.datetime "order_at"
  t.datetime "payed_at"
  t.datetime "created_at",                         null: false
  t.datetime "updated_at",                         null: false
end

=end

