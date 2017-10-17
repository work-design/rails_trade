class GoodProduce < ApplicationRecord
  belongs_to :good
  belongs_to :produce

end

=begin

create_table "good_produces", force: :cascade do |t|
    t.integer  "good_id",    limit: 4
    t.integer  "produce_id", limit: 4
    t.string   "picture",    limit: 255
    t.integer  "position",   limit: 4,   default: 0
    t.datetime "start_at"
    t.datetime "finish_at"
  end

=end