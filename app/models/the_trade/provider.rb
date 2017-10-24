class Provider < ApplicationRecord
  belongs_to :area, optional: true
  belongs_to :user
  has_many :products

end

=begin

create_table "providers", force: :cascade do |t|
  t.string   "name",        limit: 255
  t.string   "logo",        limit: 255
  t.string   "address",     limit: 255
  t.integer  "area_id",     limit: 4
  t.datetime "created_at",              null: false
  t.datetime "updated_at",              null: false
  t.string   "service_tel", limit: 255
  t.string   "service_qq",  limit: 255
end

=end
