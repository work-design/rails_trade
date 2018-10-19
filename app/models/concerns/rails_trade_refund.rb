module RailsTradeRefund

  def apply_for_refund(payment_id = nil)
    if ['unpaid', 'refunding', 'refunded'].include? self.payment_status
      return
    end

    if payment_id
      payments = self.payments.where(id: payment_id)
    else
      payments = self.payments
    end

    payments.each do |payment|
      refund = self.refunds.build(payment_id: payment.id)
      refund.type = payment.type.sub(/Payment/, '') + 'Refund'
      refund.total_amount = payment.total_amount
      refund.currency = payment.currency
      self.received_amount -= payment.total_amount
    end

    self.payment_status = 'refunding'

    self.class.transaction do
      self.confirm_refund!
      self.save!
    end
  end

  def confirm_refund!
    self.order_items.each do |oi|
      oi.confirm_refund!
    end
  end

end
