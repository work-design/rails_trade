module RailsTrade::Order
  extend ActiveSupport::Concern
  included do
    include RailsTrade::Ordering::Payment
    include RailsTrade::Ordering::Refund
    include RailsTrade::Ordering::Base
  
    attribute :payment_status, :string, default: 'unpaid'
    attribute :item_sum, :decimal, default: 0
    attribute :overall_promote_sum, :decimal, default: 0
    attribute :adjust_amount, :decimal, default: 0
    attribute :amount, :decimal, default: 0
    attribute :received_amount, :decimal, default: 0
    attribute :expire_at, :datetime, default: -> { Time.current + RailsTrade.config.expire_after }
    attribute :extra, :json, default: {}
    attribute :currency, :string, default: RailsTrade.config.default_currency
    attribute :uuid, :string, default: -> { UidHelper.nsec_uuid('OD') }
    
    belongs_to :user, optional: true
    belongs_to :buyer, polymorphic: true, optional: true
    belongs_to :cart, optional: true
    belongs_to :payment_strategy, optional: true
    has_many :payment_orders, dependent: :destroy
    has_many :payments, through: :payment_orders, inverse_of: :orders
    has_many :order_items, dependent: :destroy, autosave: true, inverse_of: :order
    has_many :refunds, dependent: :nullify, inverse_of: :order
    has_many :order_promotes, autosave: true, inverse_of: :order
  
    accepts_nested_attributes_for :order_items
    accepts_nested_attributes_for :order_promotes
  
    scope :credited, -> { where(payment_strategy_id: PaymentStrategy.where.not(period: 0).pluck(:id)) }
    scope :to_pay, -> { where(payment_status: ['unpaid', 'part_paid']) }
  
    enum payment_status: {
      unpaid: 'unpaid',
      part_paid: 'part_paid',
      all_paid: 'all_paid',
      refunding: 'refunding',
      refunded: 'refunded',
      denied: 'denied'
    }
    
    before_validation :sync_from_cart
    after_create_commit :confirm_ordered!
  end
  
  def subject
    order_items.map { |oi| oi.good&.name || 'Goods' }.join(', ')
  end
  
  def user_name
    user&.name.presence || '当前用户'
  end

  def compute_sum
    self.item_sum = order_items.sum(&:amount)
    self.overall_promote_sum = order_promotes.select(&:overall?).sum(&:amount)
    self.amount = self.item_sum + self.overall_promote_sum
  end

  def confirm_ordered!
    self.order_items.each(&:confirm_ordered!)
  end
  
  def sync_from_cart
    if cart
      self.payment_strategy_id ||= cart.payment_strategy_id
    end
  end

  def compute_received_amount
    _received_amount = self.payment_orders.where(state: :confirmed).sum(:check_amount)
    _refund_amount = self.refunds.where.not(state: :failed).sum(:total_amount)
    _received_amount - _refund_amount
  end

end
