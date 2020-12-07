module RailsTrade::Refund::StripeRefund

  def do_refund(params = {})
    return unless can_refund?

    refund = Stripe::Refund.create(charge: payment.payment_uuid, amount: (self.total_amount * 100).to_i)
    self.refund_uuid = refund.id

    if refund.status == 'succeeded'
      super
    else
      self.update reason: 'failed'
    end

    refund
  end

end
