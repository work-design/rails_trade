class PaymentOrder < ApplicationRecord
  belongs_to :order
  belongs_to :payment, inverse_of: :payment_orders

  validate :for_check_amount

  enum state: [
    :init,
    :confirmed
  ]

  after_commit :update_order_state, on: [:create, :destroy]
  after_commit :update_payment_state, on: [:create, :destroy]

  def for_check_amount
    if (same_amount + self.check_amount.to_d) > self.payment.total_amount + 1
      self.errors.add(:check_amount, 'The Amount Large than the Total')
    end
  end

  def same_amount
    PaymentOrder.where.not(id: self.id).where(payment_id: self.payment_id).sum(:check_amount)
  end

  def payment_amount
    PaymentOrder.where(payment_id: self.payment_id).sum(:check_amount)
  end

  def order_amount
    PaymentOrder.where(order_id: self.order_id).sum(:check_amount)
  end

  def update_order_state
    order.received_amount = order_amount
    if order.received_amount.to_d >= order.amount
      order.payment_status = 'all_paid'
    elsif order.received_amount.to_d > 0 && order.received_amount.to_d < order.amount
      order.payment_status = 'part_paid'
    elsif order.received_amount.to_d <= 0
      order.payment_status = 'unpaid'
    end
    order.change_to_paid!
  end

  def update_payment_state
    payment.checked_amount = payment_amount
    if payment.checked_amount >= payment.total_amount
      payment.state = 'all_checked'
      #payment.adjust_amount = payment.total_amount - payment.checked_amount
    elsif payment.checked_amount > 0 && payment.checked_amount < payment.total_amount
      payment.state = 'part_checked'
    elsif payment.checked_amount == 0
      payment.state = 'init'
    else
      payment.state = 'abusive_checked'
    end
    payment.save
  end

end