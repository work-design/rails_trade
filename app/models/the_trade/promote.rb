class Promote < ApplicationRecord
  include GoodAble
  attr_accessor :price

  has_many :charges, dependent: :delete_all

  scope :verified, -> { where(verified: true) }

  def compute_price(amount, unit = nil)
    self.charges.default_where(unit: unit, 'min-lte': amount.to_d, 'max-gt': amount.to_d).first
  end

end

# :code, :string
# :start_at, :datetime
# :finish_at, :datetime