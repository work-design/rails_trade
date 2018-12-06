class PaymentOrder < ApplicationRecord
  attribute :check_amount, :decimal
  attribute :state, :string, default: 'init'

  belongs_to :order, inverse_of: :payment_orders
  belongs_to :payment, inverse_of: :payment_orders
  has_one :refund, ->(o){ where(order_id: o.order_id) }, foreign_key: :payment_id, primary_key: :payment_id

  validate :valid_check_amount
  validates :order_id, uniqueness: { scope: :payment_id }

  enum state: {
    init: 'init',
    confirmed: 'confirmed'
  }

  def valid_check_amount
    if the_payment_amount >= self.payment.total_amount.floor + 0.99
      self.errors.add(:check_amount, 'Total amount greater than payment\'s amount')
    end

    if the_order_amount >= self.order.amount.floor + 0.99
      self.errors.add(:check_amount, 'Total amount greater than Order\' amount')
    end
  end

  def the_payment_amount
    self.payment.payment_orders.select(&:confirmed?).sum(&:check_amount).to_d
  end

  def the_order_amount
    received_amount = self.order.payment_orders.select(&:confirmed?).sum(&:check_amount).to_d
    refund_amount = self.order.refunds.where.not(state: :failed).sum(:total_amount)
    received_amount - refund_amount
  end

  def confirm
    self.state = 'confirmed'
    update_state
  end

  def confirm!
    self.state = 'confirmed'
    update_state!
    self.save!
  end

  def revert_confirm
    self.state = 'init'
    update_state
  end

  def revert_confirm!
    self.state = 'init'
    update_state!
    self.save!
  end

  private
  def update_state
    payment.checked_amount = the_payment_amount
    payment.check_state

    order.received_amount = the_order_amount
    order.check_state
  end

  def update_state!
    update_state

    order.save!
    payment.save!
  end

end unless RailsTrade.config.disabled_models.include?('PaymentOrder')
