class OrderShipment < ApplicationRecord
  belongs_to :order
  belongs_to :shipment


end unless RailsTrade.config.disabled_models.include?('OrderShipment')

# :order_id, :integer
# :shipment_id, :integer

