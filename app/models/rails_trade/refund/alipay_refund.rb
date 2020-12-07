# 支付宝批次号只能当天有效
module RailsTrade::Refund::AlipayRefund

  def do_refund(params = {})
    return unless can_refund?

    refund_params = {
      out_trade_no: order.uuid,
      refund_amount: self.total_amount.to_s,
      out_request_no: self.refund_uuid
    }

    refund_res = Alipay::Service.trade_refund(refund_params)
    refund = JSON.parse(refund_res).fetch('alipay_trade_refund_response', {})

    if refund['code'] == '10000' || refund['msg'] == 'Success'
      self.refund_uuid = refund['trade_no']
      super
    else
      self.update reason: "code: #{refund['code']}, msg: #{refund['msg']}"
    end

    refund
  end

end
