class OrderItem < ApplicationRecord
  belongs_to :order, autosave: true
  belongs_to :cart_item, optional: true
  belongs_to :good, polymorphic: true, optional: true
  belongs_to :provider, optional: true
  has_many :order_promotes

  after_initialize if: :new_record? do |oi|
    cart_item = CartItem.includes(:good).find_by(id: self.cart_item_id)
    if cart_item
      self.good_type = cart_item.good_type
      self.good_id = cart_item.good_id
      self.quantity = cart_item.quantity
      self.amount = cart_item.good.price
      #self.provider = cart_item.good.provider
    end
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



