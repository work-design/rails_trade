module BuyerAble
  extend ActiveSupport::Concern

  included do
    belongs_to :payment_strategy, optional: true
    has_many :payment_references, as: :buyer, dependent: :destroy, autosave: true
    has_many :payment_methods, through: :payment_references, autosave: true
    has_many :orders, as: :buyer

    scope :credited, -> { where(payment_strategy_id: BuyerAble.credit_ids) }
  end

  def name_detail
    "#{name} (#{id})"
  end

  def self.credit_ids
    PaymentStrategy.where(strategy: ['credit', 'deposit']).pluck(:id)
  end

end

# required attributes
# id
# name
# payment_strategy_id
