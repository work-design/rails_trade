
# payment_id
# payment_type

module OrderAble
  extend ActiveSupport::Concern

  included do
    belongs_to :buyer, polymorphic: true
    belongs_to :payment_strategy, optional: true

    has_many :payment_orders, inverse_of: :order, dependent: :destroy
    has_many :payments, through: :payment_orders
    has_many :order_items, dependent: :destroy, autosave: true
    has_many :refunds, dependent: :nullify

    after_initialize if: :new_record? do |o|
      self.uuid = UidHelper.nsec_uuid('OD')
    end

    enum payment_status: {
      unpaid: 0,
      part_paid: 1,
      all_paid: 2,
      refunded: 3,
    }
    enum payment_type: {
      paypal: 'paypal',
      alipay: 'alipay'
    }

    scope :credited, -> { where(payment_strategy_id: OrderAble.credit_ids) }
  end


  def unreceived_amount
    self.amount - self.received_amount
  end

  def init_received_amount
    self.payment_orders.sum(:check_amount)
  end

  def pending_payments
    Payment.where.not(id: self.payment_orders.pluck(:payment_id)).where(payment_method_id: self.buyer.payment_method_ids, state: ['init', 'part_checked'])
  end

  def exists_payments
    Payment.where.not(id: self.payment_orders.pluck(:payment_id)).exists?(payment_method_id: self.buyer.payment_method_ids, state: ['init', 'part_checked'])
  end

  def pay_result
    if self.amount == 0
      return paid_result
    end

    if self.payment_status == 'all_paid'
      return self
    end

    if self.paypal?
      self.paypal_result
    elsif self.alipay?
      self.alipay_result
    end
    self
  end

  def paid_result
    self.payment_status = 'all_paid'
    self.received_amount = self.amount
    self.confirm_paid!
    self
  end

  def apply_for_refund
    if self.payments.size == 1
      payment = self.payments.first
      refund = Refund.find_or_initialize_by(order_id: self.id, payment_id: payment.id)
      refund.type = payment.type.sub(/Payment/, '') + 'Refund'
      refund.total_amount = payment.total_amount
      refund.currency = payment.currency

      self.payment_status = 'refunded'

      self.class.transaction do
        self.save!
        self.confirm_refund!
        refund.save!
      end
    else

    end
  end

  def confirm_paid!

  end
  
  def confirm_refund!

  end

  def self.credit_ids
    PaymentStrategy.where.not(period: 0).pluck(:id)
  end

end


