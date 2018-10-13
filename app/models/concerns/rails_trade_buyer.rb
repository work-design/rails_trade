module RailsTradeBuyer
  extend ActiveSupport::Concern

  included do
    attribute :name, :string
    attribute :deposit_ratio, :integer, default: 100
    attribute :payment_strategy_id, :integer

    belongs_to :payment_strategy, optional: true

    has_many :orders, as: :buyer, inverse_of: :buyer
    has_many :cart_items, as: :buyer, dependent: :destroy
    has_many :addresses, as: :buyer, dependent: :destroy

    has_many :promote_buyers, as: :buyer, dependent: :destroy
    has_many :promotes, ->{ special }, through: :promote_buyers

    has_many :payment_references, as: :buyer, dependent: :destroy, autosave: true
    has_many :payment_methods, through: :payment_references, autosave: true


    scope :credited, -> { where(payment_strategy_id: self.credit_ids) }

    validates :deposit_ratio, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

    def self.credit_ids
      PaymentStrategy.where.not(period: 0).pluck(:id)
    end
    RailsTrade.buyer_classes << self.name
  end

  def name_detail
    "#{name} (#{id})"
  end

  def last_overdue_date
    orders.order(overdue_date: :asc).first&.overdue_date
  end

end


# required attributes
# id
# :name
# :payment_strategy_id
# :deposit_ratio, :integer, default: 100, comment: '最小预付比例'
