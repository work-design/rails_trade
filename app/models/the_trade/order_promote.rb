class OrderPromote < ApplicationRecord
  belongs_to :order, inverse_of: :order_promotes
  belongs_to :order_item, optional: true
  belongs_to :promote
  belongs_to :charge


end

# :order_id, :integer
# :order_item_id :integer

