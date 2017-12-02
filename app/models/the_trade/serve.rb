class Serve < ApplicationRecord
  include GoodAble
  attr_accessor :price
  serialize :extra, Array

  has_many :charges, class_name: 'ServeCharge', dependent: :delete_all

  scope :verified, -> { where(verified: true) }
  scope :special, -> { where(verified: true, overall: false) }
  scope :overall, -> { where(verified: true, overall: true) }

  enum scope: {
    'total': 'total',
    'single': 'single'
  }

  def compute_price(amount, extra_hash = {})
    extra_hash.stringify_keys!
    query = { 'min-lte': amount.to_d, 'max-gt': amount.to_d }.merge(extra_hash.slice(*extra))
    charge = self.charges.default_where(query).first
    charge.subtotal = charge.final_price(amount) if charge
    charge
  end

end

# :start_at, :datetime
# :finish_at, :datetime