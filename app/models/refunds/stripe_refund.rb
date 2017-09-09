class StripeRefund < Refund

  def do_refund(params = {})
    return unless can_refund?


    refund = Stripe::Refund.create(charge: payment.payment_uuid, amount: self.total_amount * 100)

    order.payment_status = 'refunded'
    order.received_amount -= self.total_amount

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
