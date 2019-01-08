class Promote < ApplicationRecord
  attribute :price
  attribute :start_at, :datetime
  attribute :finish_at, :datetime
  attribute :sequence, :integer

  has_many :charges, class_name: 'PromoteCharge', dependent: :delete_all
  has_many :promote_goods, dependent: :destroy
  has_many :promote_buyers, dependent: :destroy

  scope :verified, -> { where(verified: true) }
  scope :overall_goods, -> { valid.where(overall_goods: true) }  # 适用于所有商品
  scope :special_goods, -> { valid.where(overall_goods: false) }  # 仅适用于特定商品
  scope :overall_buyers, -> { valid.where(overall_buyers: true) }  # 适用于所有顾客
  scope :special_buyers, -> { valid.where(overall_buyers: false) }  # 仅适用于特定顾客
  scope :valid, -> { t = Time.now; verified.default_where('start_at-lte': t, 'finish_at-gte': t) }

  validates :code, uniqueness: true
  validates :start_at, presence: true
  validates :finish_at, presence: true

  after_commit :delete_cache, on: [:create, :destroy]
  after_update_commit :delete_cache, if: -> { saved_change_to_sequence? }

  enum scope: {
    total: 'total', # 适用于多个商品一起计算
    single: 'single'  # 适用于单独计算商品
  }

  def compute_price(amount, extra_hash = {})
    extra_hash.stringify_keys!

    query = { 'min-lte': amount.to_d, 'max-gt': amount.to_d }.merge(extra_hash.slice(*extra))
    charge = self.charges.default_where(query).first
    if charge
      charge.subtotal = -(amount - charge.final_price(amount))
    end
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
