module Trade
  module Model::Refund::StripeRefund

    def do_refund(params = {})
      return unless can_refund?

      refund = Stripe::Refund.create(charge: payment.payment_uuid, amount: (self.total_amount * 100).to_i)
      self.refund_uuid = refund.id

      if refund.status == 'succeeded'
        self.state = 'completed'
        self.refunded_at = Time.current
      else
        self.state = 'failed'
      end

      refund
    end

  end
end
