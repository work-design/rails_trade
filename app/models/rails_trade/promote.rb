class Promote < ApplicationRecord
  attribute :price
  attribute :start_at, :datetime
  attribute :finish_at, :datetime
  attribute :sequence, :integer

  has_many :charges, class_name: 'PromoteCharge', dependent: :delete_all

  scope :special, -> { where(verified: true, overall: false) }
  scope :overall, -> { where(verified: true, overall: true) }

  after_commit :delete_cache, on: [:create, :destroy]
  after_update_commit :delete_cache, if: -> { saved_change_to_sequence? }

  enum scope: {
    total: 'total',
    single: 'single'
  }

  def compute_price(amount, extra_hash = {})
    extra_hash.stringify_keys!

    query = { 'min-lte': amount.to_d, 'max-gt': amount.to_d }.merge(extra_hash.slice(*extra))
    charge = self.charges.default_where(query).first
    charge.subtotal = charge.final_price(amount) if charge
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

end unless RailsTrade.config.disabled_models.include?('Promote')
