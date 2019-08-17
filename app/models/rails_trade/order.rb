module RailsTrade::Order
  extend ActiveSupport::Concern
  include RailsTrade::Ordering::Payment
  include RailsTrade::Ordering::Refund

  included do
    delegate :url_helpers, to: 'Rails.application.routes'
    
    attribute :payment_status, :string, default: 'unpaid'
    attribute :received_amount, :decimal, default: 0

    attribute :expire_at, :datetime, default: -> { Time.current + RailsTrade.config.expire_after }
    attribute :extra, :json, default: {}
    attribute :currency, :string, default: RailsTrade.config.default_currency
    attribute :uuid, :string
    
    belongs_to :buyer, polymorphic: true, optional: true
    belongs_to :cart, optional: true
    belongs_to :payment_strategy, optional: true
    has_many :payment_orders, dependent: :destroy
    has_many :payments, through: :payment_orders, inverse_of: :orders
    has_many :refunds, dependent: :nullify, inverse_of: :order
  
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
    
    after_initialize if: :new_record? do
      self.user_id ||= buyer.user_id if buyer.respond_to?(:user_id)
    end
    before_validation :sync_from_cart
    after_create_commit :confirm_ordered!
  end
  
  def subject
    trade_items.map { |oi| oi.good&.name || 'Goods' }.join(', ')
  end
  
  def user_name
    user&.name.presence || "#{user&.id}"
  end

  def amount_money
    amount.to_money(self.currency)
  end
  
  def compute_promote
  end

  def metering_attributes
    attributes.slice 'quantity', 'amount'
  end
  
  def sync_from_cart
    self.uuid ||= UidHelper.nsec_uuid('OD')
    if cart
      self.payment_strategy_id ||= cart.payment_strategy_id
    end
  end

  def confirm_ordered!
    self.trade_items.each(&:confirm_ordered!)
  end

  def compute_received_amount
    _received_amount = self.payment_orders.where(state: :confirmed).sum(:check_amount)
    _refund_amount = self.refunds.where.not(state: :failed).sum(:total_amount)
    _received_amount - _refund_amount
  end

end
