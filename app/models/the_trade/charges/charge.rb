class Charge < ApplicationRecord
  belongs_to :promote, foreign_key: :code, primary_key: :code

  validates :max, numericality: { greater_than: -> (o) { o.min } }, allow_nil: true
  validates :min, numericality: { less_than: -> (o) { o.max } }, allow_nil: true

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