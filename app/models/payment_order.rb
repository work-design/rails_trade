class PaymentOrder < ApplicationRecord
  belongs_to :order
  belongs_to :payment


  validate :for_check_amount

  def for_check_amount
    amount = PaymentOrder.where.not(id: self.id).where(payment_id: self.payment_id).sum(:check_amount)

    if amount + self.check_amount.to_d > self.payment.total_amount
      self.errors.add(:check_amount, 'The Amount Large than the Total')
    end
  end

end