class OrderShipment < ApplicationRecord
  belongs_to :order
  belongs_to :shipment


end

# :order_id, :integer
# :shipment_id, :integer

