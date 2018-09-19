class GoodProduce < ApplicationRecord
  belongs_to :good
  belongs_to :produce

end unless RailsTrade.config.disabled_models.include?('GoodProduce')


# t.integer  "good_id",    limit: 4
# t.integer  "produce_id", limit: 4
# t.string   "picture",    limit: 255
# t.integer  "position",   limit: 4,   default: 0
# t.datetime "start_at"
# t.datetime "finish_at"

