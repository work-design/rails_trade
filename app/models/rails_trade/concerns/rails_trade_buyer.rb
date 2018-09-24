module RailsTradeBuyer
  extend ActiveSupport::Concern

  included do
    attribute :name, :string
    attribute :deposit_ratio, :integer, default: 100
    attribute :payment_strategy_id, :integer

    belongs_to :payment_strategy, optional: true
    has_many :users, foreign_key: :buyer_id, dependent: :nullify
    has_many :orders, foreign_key: :buyer_id, inverse_of: :buyer
    has_many :payment_references, foreign_key: :buyer_id, dependent: :destroy, autosave: true
    has_many :payment_methods, through: :payment_references, autosave: true
    has_many :cart_items, foreign_key: :buyer_id
    has_many :addresses, foreign_key: :buyer_id, dependent: :destroy
    has_many :promote_buyers, foreign_key: :buyer_id, dependent: :destroy
    has_many :promotes, ->{ special }, through: :promote_buyers

    CartItem.belongs_to :buyer, class_name: self.name, optional: true
    Order.belongs_to :buyer, class_name: self.name, optional: true
    Address.belongs_to :buyer, class_name: self.name, optional: true
    PaymentReference.belongs_to :buyer, class_name: self.name, optional: true
    PromoteBuyer.belongs_to :buyer, class_name: self.name

    scope :credited, -> { where(payment_strategy_id: self.credit_ids) }

    validates :deposit_ratio, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

    def self.credit_ids
      PaymentStrategy.where.not(period: 0).pluck(:id)
    end
    RailsTrade.buyer_class = self
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
