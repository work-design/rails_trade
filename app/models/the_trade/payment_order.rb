class PaymentOrder < ApplicationRecord
  belongs_to :order, inverse_of: :payment_orders
  belongs_to :payment, inverse_of: :payment_orders

  validate :for_check_amount

  enum state: [
    :init,
    :confirmed
  ]

  def for_check_amount
    if (same_payment_amount + self.check_amount.to_d) > self.payment.total_amount.floor + 0.99
      self.errors.add(:check_amount, 'The Amount Large than the Total Payment')
    end

    if (same_order_amount + self.check_amount.to_d) > self.order.amount.floor + 0.99
      self.errors.add(:check_amount, 'The Amount Large than the Total Order')
    end
  end

  def same_payment_amount
    PaymentOrder.where.not(id: self.id).where(payment_id: self.payment_id).sum(:check_amount)
  end

  def same_order_amount
    received = PaymentOrder.where.not(id: self.id).where(order_id: self.order_id).sum(:check_amount)
    refund = Refund.where(payment_id: payment_id, order_id: order_id).sum(:total_amount)
    received - refund
  end

  def payment_amount
    PaymentOrder.where(payment_id: self.payment_id, state: 'confirmed').sum(:check_amount)
  end

  def order_amount
    PaymentOrder.where(order_id: self.order_id, state: 'confirmed').sum(:check_amount)
  end

  def confirm!
    self.state = 'confirmed'

    begin
      self.save!

      self.class.transaction do
        update_order_state
        update_payment_state
      end
    rescue => e
      raise e
    end
  end

  def revert_confirm!
    self.state = 'init'
    self.save!

    self.class.transaction do
      update_order_state
      update_payment_state
    end
  end

  def update_order_state
    order.received_amount = order_amount
    order.check_state!
  end

  def update_payment_state
    payment.checked_amount = payment_amount
    payment.check_state!
  end

end