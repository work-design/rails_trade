class OrderItem < ApplicationRecord
  belongs_to :order, autosave: true
  belongs_to :cart_item, optional: true
  belongs_to :good, polymorphic: true, optional: true


  after_initialize if: :new_record? do |oi|
    cart_item = CartItem.includes(:good).find self.cart_item_id
    self.good_type = cart_item.good_type
    self.good_id = cart_item.good_id
    self.quantity = cart_item.quantity
    self.amount = cart_item.good.price
  end

end

# :cart_item_id, :integer
# :good_id, :integer,     limit: 4
# :quantity, :float
# :unit, :string
# :number, :integer, limit: 4, default: 1
# :total_price, :decimal, limit: 24
# :order_at :datetime
# :payed_at :datetime



