class Promote < ApplicationRecord
  include GoodAble
  attr_accessor :price

  has_many :charges, dependent: :delete_all

  def compute_price(amount, unit)
    charge = self.charges.default_where(unit: unit, 'min-lte': amount.to_d, 'max-gt': amount.to_d).first
    if charge
      charge.final_price(amount)
    else
      0
    end
  end

end

# :code, :string
# :start_at, :datetime
# :finish_at, :datetime