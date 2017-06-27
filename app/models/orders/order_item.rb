class OrderItem < ApplicationRecord
  belongs_to :good


  def compute_fee
    if number.blank? && self.unit.present?
      self.number = (self.quantity.to_f / good.quantity.to_f).ceil
    end

    if self.unit
      self.amount = Charge.price(quantity, self.unit)
    else
      self.amount = self.number * good.price
    end
  end

end


# :good_id, :integer,     limit: 4
# :quantity, :float
# :unit, :string
# :number, :integer, limit: 4, default: 1
# :total_price, :decimal, limit: 24
# :order_at :datetime
# :payed_at :datetime



