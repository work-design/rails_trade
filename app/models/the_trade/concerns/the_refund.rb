module TheRefund

  def apply_for_refund(payment_id = nil)

    refunds = []
    self.payments.each do |payment|
      refund = Refund.find_or_initialize_by(
                        order_id: self.id,
                        payment_id: payment.id)

      refund.type         = payment.type.sub(/Payment/, '') + 'Refund'
      refund.total_amount = payment.total_amount
      refund.currency     = payment.currency
      refunds << refund
    end

    self.payment_status   = 'refunding'
    self.class.transaction do
      refunds.each {|refund| refund.save! }
      self.save!
      self.confirm_refund!
    end
  end

  def confirm_refund!
    self.order_items.each do |oi|
      oi.confirm_refund!
    end
  end

end
