class Serve < ApplicationRecord
  include GoodAble
  attr_accessor :price

  has_many :charges, class_name: 'ServeCharge', dependent: :delete_all

  scope :verified, -> { where(verified: true) }

  after_commit :delete_cache, on: [:create, :destroy]
  #after_update_commit :delete_cache, if: -> { sequence_changed? }

  enum scope: {
    'total': 'total',
    'single': 'single'
  }

  def compute_price(amount, price = 0, extra = {})
    query = { 'min-lte': amount.to_d, 'max-gt': amount.to_d }.merge(extra)
    charge = self.charges.default_where(query).first
    charge.subtotal = charge.final_price(price)
    charge
  end

  def self.sequence
    Rails.cache.fetch('promotes/sequence') do
      self.select(:sequence).distinct.pluck(:sequence).sort
    end
  end

  private
  def delete_cache
    ['promotes/sequence'].each do |c|
      Rails.cache.delete(c)
    end
  end

end

# :start_at, :datetime
# :finish_at, :datetime