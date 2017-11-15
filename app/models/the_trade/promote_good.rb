class PromoteGood < ApplicationRecord
  belongs_to :good, polymorphic: true
  belongs_to :promote

end

# :order_id, :integer
# :order_item_id :integer

