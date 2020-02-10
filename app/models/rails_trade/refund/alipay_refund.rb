# 支付宝批次号只能当天有效
module RailsTrade::Refund::AlipayRefund

  def do_refund(params = {})
    return unless can_refund?

    refund_params = {
      out_trade_no: self.order.uuid,
      refund_amount: self.total_amount.to_s,
      out_request_no: self.refund_uuid
    }

    refund_res = Alipay::Service.trade_refund(refund_params)

    order.payment_status = 'refunded'
    self.operator_id = params[:operator_id]

    refund = JSON.parse(refund_res).fetch('alipay_trade_refund_response', {})

    if refund['code'] == '10000' || refund['msg'] == 'Success'
      self.refund_uuid = refund['trade_no']
      self.state = 'completed'
      self.refunded_at = Time.now
      self.class.transaction do
        order.save!
        self.save!
      end
    else
      self.update reason: "code: #{refund['code']}, msg: #{refund['msg']}"
    end
    refund
  end

end
