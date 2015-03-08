class Payment < ActiveRecord::Base
  has_many :products
end

=begin

create_table "payments", force: :cascade do |t|
  t.integer "user_id",     limit: 4
  t.integer "order_id",    limit: 4
  t.float   "total_price", limit: 24
end

=end