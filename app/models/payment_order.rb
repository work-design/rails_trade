class PaymentOrder < ApplicationRecord
  belongs_to :order
  belongs_to :payment

  validate :for_check_amount

  after_commit :update_order_state

  def for_check_amount
    if same_amount + self.check_amount.to_d > self.payment.total_amount
      self.errors.add(:check_amount, 'The Amount Large than the Total')
    end
  end

  def same_amount
    PaymentOrder.where.not(id: self.id).where(payment_id: self.payment_id).sum(:check_amount)
  end

  def order_amount
    PaymentOrder.where(order_id: self.order_id).sum(:check_amount)
  end

  def update_order_state
    order.received_amount = order_amount
    if order.received_amount >= order.amount
      order.payment_status = 'all_paid'
    elsif order.received_amount > 0 && order.received_amount < order.amount
      order.payment_status = 'part_paid'
    elsif order.received_amount <= 0
      order.payment_status = 'unpaid'
    end
    order.save
  end

end