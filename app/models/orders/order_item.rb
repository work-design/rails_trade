class OrderItem < ApplicationRecord
  belongs_to :good




  def compute_fee(total)
    number = (total / good.quantity).ceil
    Charge.price(number, unit)
  end

end


# :good_id, :integer,     limit: 4
# :price,       limit: 24
# :number,    limit: 4,  default: 1
#  t.float    "total_price", limit: 24
#  t.datetime "order_at"
#  t.datetime "payed_at"



