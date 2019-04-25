module RailsTrade::Buyer
  extend ActiveSupport::Concern

  included do
    attribute :name, :string
    attribute :deposit_ratio, :integer, default: 100  # 最小预付比例
    attribute :payment_strategy_id, :integer

    belongs_to :payment_strategy, optional: true

    has_one :cart, as: :buyer
    has_many :orders, as: :buyer, inverse_of: :buyer
    has_many :cart_items, as: :buyer, dependent: :destroy

    has_many :promote_buyers, as: :buyer, dependent: :destroy
    has_many :promotes, ->{ special_goods }, through: :promote_buyers

    has_many :payment_references, as: :buyer, dependent: :destroy, autosave: true
    has_many :payment_methods, through: :payment_references, autosave: true

    scope :credited, -> { where(payment_strategy_id: self.credit_ids) }

    validates :deposit_ratio, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

    def self.credit_ids
      PaymentStrategy.where.not(period: 0).pluck(:id)
    end
    RailsTrade.buyer_classes << self.name unless RailsTrade.buyer_classes.include?(self.name)
  end

  def cart
    super ? super : create_cart
  end

  def name_detail
    "#{name} (#{id})"
  end

  def last_overdue_date
    orders.order(overdue_date: :asc).first&.overdue_date
  end

end
