class OrderPromote < ApplicationRecord
  belongs_to :order, inverse_of: :order_promotes
  belongs_to :order_item, optional: true
  belongs_to :promote
  belongs_to :promote_charge, optional: true

end unless RailsTrade.config.disabled_models.include?('OrderPromtote')

# :order_id, :integer
# :order_item_id :integer

