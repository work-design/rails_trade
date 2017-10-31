class Promote < ApplicationRecord
  include GoodAble
  attr_accessor :price

  has_many :charges, primary_key: :code, foreign_key: :code

  validates :code, uniqueness: true

  enum scope: [
    :init,
    :wide
  ]

  def compute_price(amount, unit)
    charge = self.charges.default_where(unit: unit, 'min-lte': amount.to_d, 'max-gt': amount.to_d).first
    charge.final_price(amount)
  end

end

# :code, :string
# :start_at, :datetime
# :finish_at, :datetime