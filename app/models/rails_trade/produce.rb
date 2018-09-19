class Produce < ApplicationRecord
  has_many :good_produces

end unless RailsTrade.config.disabled_models.include?('Produce')

=begin

# 生产工艺

t.string   "product",    limit: 255
t.string   "name",       limit: 255
t.text     "content",    limit: 65535
t.datetime "start_at"
t.datetime "finish_at"
t.datetime "created_at"
t.datetime "updated_at"

=end
