module TheRefund

  def apply_for_refund(payment_id = nil)
    if payment_id
      payment = self.payments.find_by(id: payment_id)
    else
      payment = self.payments.first
    end

    refund =
      Refund.find_or_initialize_by(order_id: self.id, payment_id: payment.id)
    refund.type         = payment.type.sub(/Payment/, '') + 'Refund'
    refund.total_amount = payment.total_amount
    refund.currency     = payment.currency

    self.payment_status   = 'refunding'
    self.received_amount -= payment.total_amount

    self.class.transaction do
      self.save!
      self.confirm_refund!
      refund.save!
    end
  end

  def confirm_refund!
    self.order_items.each do |oi|
      oi.confirm_refund!
    end
  end

end
