class Promote < ApplicationRecord
  include GoodAble
  attr_accessor :price

  has_many :charges, dependent: :delete_all

  scope :special, -> { where(verified: true, overall: false) }
  scope :overall, -> { where(verified: true, overall: true) }

  enum scope: {
    'total': 'total',
    'single': 'single'
  }

  def compute_price(amount, extra = {})
    query = { 'min-lte': amount.to_d, 'max-gt': amount.to_d }.merge(extra)
    self.charges.default_where(query).first
  end

end

# :start_at, :datetime
# :finish_at, :datetime