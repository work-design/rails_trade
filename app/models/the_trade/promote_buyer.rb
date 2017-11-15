class PromoteBuyer < ApplicationRecord
  belongs_to :buyer, class_name: '::Buyer', foreign_key: :buyer_id
  belongs_to :promote



end

# :order_id, :integer
# :order_item_id :integer

