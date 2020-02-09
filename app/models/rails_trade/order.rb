module RailsTrade::Order
  extend ActiveSupport::Concern
  include RailsTrade::Ordering::Payment
  include RailsTrade::Ordering::Refund

  included do
    attribute :uuid, :string
    attribute :state, :string
    attribute :item_amount, :decimal, precision: 10, scale: 2
    attribute :overall_additional_amount, :decimal, precision: 10, scale: 2
    attribute :overall_reduced_amount, :decimal, precision: 10, scale: 2
    attribute :amount, :decimal, precision: 10, scale: 2
    attribute :received_amount, :decimal, precision: 10, scale: 2
    attribute :payment_id, :integer, comment: 'for paypal'
    attribute :myself, :boolean, default: true
    attribute :note, :string, limit: 4096
    attribute :expire_at, :datetime
    attribute :payment_status, :string, default: 'unpaid', index: true
    attribute :received_amount, :decimal, default: 0
    attribute :expire_at, :datetime, default: -> { Time.current + RailsTrade.config.expire_after }
    attribute :extra, :json, default: {}
    attribute :currency, :string, default: RailsTrade.config.default_currency
    attribute :lock_version, :integer

    belongs_to :organ, optional: true
    belongs_to :cart, optional: true
    belongs_to :user, optional: true
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
      if cart
        self.user_id = cart.user_id
        self.payment_strategy_id = cart.payment_strategy_id
      end
    end
    before_validation do
      self.uuid ||= UidHelper.nsec_uuid('OD')
    end
    after_save :sync_from_cart, if: -> { saved_change_to_cart_id? && cart }
    after_create_commit :confirm_ordered!

    delegate :url_helpers, to: 'Rails.application.routes'
  end

  def subject
    trade_items.map { |oi| oi.good&.name || 'Goods' }.join(', ')
  end

  def user_name
    user&.name.presence || "#{user&.id}"
  end

  def amount_money
    amounto_money(self.currency)
  end

  def compute_promote
  end

  def metering_attributes
    attributes.slice 'quantity', 'amount'
  end

  def sync_from_cart
    cart.trade_items.checked.default_where(myself: myself).update_all(trade_type: self.class.name, trade_id: self.id)
    cart.trade_promotes.update_all(trade_type: self.class.name, trade_id: self.id)

    self.compute_amount
    self.save
  end

  def confirm_ordered!
    self.trade_items.each(&:confirm_ordered!)
  end

  def compute_received_amount
    _received_amount = self.payment_orders.where(state: 'confirmed').sum(:check_amount)
    _refund_amount = self.refunds.where.not(state: 'failed').sum(:total_amount)
    _received_amount - _refund_amount
  end

end
