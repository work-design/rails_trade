class Charge < ApplicationRecord
  attr_accessor :subtotal, :discount
  belongs_to :promote

  validates :max, numericality: { greater_than: -> (o) { o.min } }
  validates :min, numericality: { less_than: -> (o) { o.max } }

  def final_price(amount = 1)
    raise 'Should Implement in Subclass'
  end

  def discount_price(amount, number)
    - ( final_price(amount * number) - final_price(amount) )
  end

end

# :min, :integer
# :max, :integer
# :price, :decimal
# :type, :string     # SingleCharge / TotalCharge