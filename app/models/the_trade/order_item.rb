class OrderItem < ApplicationRecord
  belongs_to :order, autosave: true
  belongs_to :cart_item, optional: true
  belongs_to :good, polymorphic: true, optional: true






end

# :cart_item_id, :integer
# :good_id, :integer,     limit: 4
# :quantity, :float
# :unit, :string
# :number, :integer, limit: 4, default: 1
# :total_price, :decimal, limit: 24
# :order_at :datetime
# :payed_at :datetime



