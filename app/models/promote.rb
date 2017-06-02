class Promote < ApplicationRecord
  has_many :products


end

=begin

create_table "promotes", force: :cascade do |t|
  t.string   "name",         limit: 255
  t.integer  "price_reduce", limit: 4
  t.datetime "start_at"
  t.datetime "finish_at"
end

=end
