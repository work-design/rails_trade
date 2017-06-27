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
# :price,       limit: 24
# :number,    limit: 4,  default: 1
#  t.float    "total_price", limit: 24
#  t.datetime "order_at"
#  t.datetime "payed_at"



