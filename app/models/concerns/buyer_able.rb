module BuyerAble
  extend ActiveSupport::Concern

  included do
    belongs_to :payment_strategy, optional: true
    has_many :payment_references, as: :buyer, dependent: :destroy, autosave: true
    has_many :payment_methods, through: :payment_references, autosave: true
    has_many :orders, as: :buyer

    scope :credited, -> { where(payment_strategy_id: BuyerAble.credit_ids) }

    validates :deposit_ratio, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  end

  def name_detail
    "#{name} (#{id})"
  end

  def self.credit_ids
    PaymentStrategy.where.not(period: 0).pluck(:id)
  end

end

# required attributes
# id
# name
# payment_strategy_id
# deposit_ratio, :integer, default: 100, comment: '最小预付比例'
