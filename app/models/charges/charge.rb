class Charge < ApplicationRecord

  def self.price(amount, unit)
    charge = Charge.default_where(unit: unit, 'min-lte': amount.to_d, 'max-gt': amount.to_d).first
    charge.final_price(amount)
  end

end

# :unit, :string
# :min, :integer
# :max, :integer
# :price, :decimal
# :type, :string     # SingleCharge / TotalCharge