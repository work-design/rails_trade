class Area < ApplicationRecord

  has_many :providers

end

=begin

create_table "areas", force: true do |t|
  t.string  "name",      limit: 255, default: ""
  t.string  "province",  limit: 255
  t.string  "city",      limit: 255
  t.string  "district",  limit: 255
  t.integer "depth",     limit: 4,   default: 0
  t.integer "parent_id", limit: 4
end

=end
