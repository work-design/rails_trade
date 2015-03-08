class OrderShipment < ActiveRecord::Base

  belongs_to :good
  belongs_to :shipment


end

=begin

create_table "order_shipments", force: :cascade do |t|
  t.integer "order_id",    limit: 4
  t.integer "shipment_id", limit: 4
end

=end

