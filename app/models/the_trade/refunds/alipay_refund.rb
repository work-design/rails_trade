class AlipayRefund < Refund
  
  def do_refund(params = {})
    return unless can_refund?

    refund_params = {
      out_batch_no: self.order.uuid,
      refund_amount: self.total_amount.to_s,
      out_request_no: self.refund_uuid
    }

    refund = Alipay::Service.trade_refund(refund_params)

    order.payment_status = 'refunded'

    self.operator_id = params[:operator_id]
    # self.refund_uuid = refund.id
    #
    # if refund.status == 'succeeded'
    #   self.state = 'completed'
    #   self.refunded_at = Time.now
    #   self.class.transaction do
    #     order.save!
    #     self.save!
    #   end
    # else
    #   self.update reason: 'failed'
    # end
    refund
  end

end
