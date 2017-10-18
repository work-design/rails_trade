class GoodPartner < ApplicationRecord


end


=begin

create_table "good_partners", force: :cascade do |t|
  t.integer "good_id",    limit: 4
  t.integer "partner_id", limit: 4
end

=end
