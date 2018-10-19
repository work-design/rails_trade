class PaymentOrder < ApplicationRecord
  attribute :check_amount, :decimal
  attribute :state, :string, default: 'init'

  belongs_to :order, inverse_of: :payment_orders
  belongs_to :payment, inverse_of: :payment_orders
  belongs_to :refund, foreign_key: :payment_id
  has_one :refund, ->(o){ where(order_id: o.order_id) }, foreign_key: :payment_id, primary_key: :payment_id


  validate :for_check_amount
  validates :order_id, uniqueness: { scope: :payment_id }

  enum state: {
    init: 'init',
    confirmed: 'confirmed'
  }

  def for_check_amount
    if same_payment_amount >= self.payment.total_amount.floor + 0.99
      self.errors.add(:check_amount, 'The Amount Large than the Total Payment')
    end

    if same_order_amount >= self.order.amount.floor + 0.99
      self.errors.add(:check_amount, 'The Amount Large than the Total Order')
    end
  end

  def same_payment_amount
    self.payment.payment_orders.select(&:confirmed?).sum(&:check_amount)
  end

  def same_order_amount
    received = self.order.payment_orders.select(&:confirmed?).sum(&:check_amount)
    refund = self.order.refunds.reject(&:failed?).sum(&:total_amount)
    received - refund
  end

  def confirm!
    self.confirm
    self.save!
  end

  def confirm
    self.state = 'confirmed'
    update_state
  end

  def revert_confirm!
    self.revert_confirm
    self.save!
  end

  def revert_confirm
    self.state = 'init'
    update_state
  end

  def update_state
    order.check_state
    payment.check_state
  end

  def update_state!
    update_state

    order.save!
    payment.save!
  end


end unless RailsTrade.config.disabled_models.include?('PaymentOrder')
