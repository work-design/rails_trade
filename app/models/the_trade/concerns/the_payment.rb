# payment_id
# payment_type
# amount
# received_amount
module ThePayment

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
    elsif self.stripe?
      self.stripe_result
    end
    self
  end

  def paid_result
    self.payment_status = 'all_paid'
    self.received_amount = self.amount
    self.confirm_paid!
    self
  end

  def confirm_paid!

  end

  def check_state
    if self.received_amount.to_d >= self.amount
      self.payment_status = 'all_paid'
      self.confirm_paid!
    elsif self.received_amount.to_d > 0 && self.received_amount.to_d < self.amount
      self.payment_status = 'part_paid'
    elsif self.received_amount.to_d <= 0
      self.payment_status = 'unpaid'
    end
  end

  def check_state!
    self.check_state
    self.save!
  end

end