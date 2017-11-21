class Buyer < ApplicationRecord
  belongs_to :payment_strategy, optional: true
  has_many :orders, foreign_key: :buyer_id
  has_many :payment_references, foreign_key: :buyer_id, dependent: :destroy, autosave: true
  has_many :payment_methods, through: :payment_references, autosave: true
  has_many :cart_items, foreign_key: :buyer_id
  has_many :addresses, foreign_key: :buyer_id, dependent: :destroy
  has_many :promote_buyers, foreign_key: :buyer_id, dependent: :destroy
  has_many :promotes, ->{ special }, through: :promote_buyers

  scope :credited, -> { where(payment_strategy_id: self.credit_ids) }

  validates :deposit_ratio, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  def name_detail
    "#{name} (#{id})"
  end

  def last_overdue_date
    orders.order(overdue_date: :asc).first&.overdue_date
  end

  def self.credit_ids
    PaymentStrategy.where.not(period: 0).pluck(:id)
  end

end


# required attributes
# id
# :name
# :payment_strategy_id
# :deposit_ratio, :integer, default: 100, comment: '最小预付比例'
