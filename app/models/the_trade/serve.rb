class Serve < ApplicationRecord
  attr_accessor :price
  serialize :extra, Array

  belongs_to :deal, polymorphic: true, optional: true
  has_many :charges, class_name: 'ServeCharge', dependent: :delete_all
  has_many :serve_goods, dependent: :delete_all

  scope :verified, -> { where(verified: true) }
  scope :special, -> { where(verified: true, overall: false) }
  scope :overall, -> { where(verified: true, overall: true) }
  scope :default, -> { where(verified: true, default: true) }
  scope :for_sale, -> { where(verified: true, default: false) }

  enum scope: {
    'total': 'total',
    'single': 'single'
  }

  def compute_price(amount, extra_hash = {})
    extra_hash.stringify_keys!

    if self.contain_max
      range = { 'min-lte': amount.to_d, 'max-gte': amount.to_d }
    else
      range = { 'min-lte': amount.to_d, 'max-gt': amount.to_d }
    end

    query = range.merge(extra_hash.slice(*extra))
    charge = self.charges.default_where(query).first
    if charge
      charge.subtotal = charge.final_price(amount)
      charge.default_subtotal = charge.subtotal
    else
      charge = self.charges.build
      charge.subtotal = 0
    end
    charge
  end

end

# :start_at, :datetime
# :finish_at, :datetime