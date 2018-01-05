class StripeRefund < Refund

  def do_refund(params = {})
    return unless can_refund?

    refund = Stripe::Refund.create(
                              charge: payment.payment_uuid,
                              amount: (order.refund_price * 100).to_i
                             )

    order.payment_status = 'refunded'

    self.operator_id = params[:operator_id]
    self.refund_uuid = refund.id

    if refund.status == 'succeeded'
      self.state = 'completed'
      self.refunded_at = Time.now
      self.class.transaction do
        order.save!
        self.save!
      end
    else
      self.update reason: 'failed'
    end
    refund
  end

end
