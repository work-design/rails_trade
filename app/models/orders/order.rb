class Order < ApplicationRecord
  belongs_to :good
  belongs_to :buyer
  has_many :payment_orders, dependent: :destroy
  has_many :payments, through: :payment_orders

end

# :buyer_id, :integer
# :amount, :decimal

