class WxpayRefund < Refund

  def transaction_id
    refunded_payment&.payment_uuid
  end

  def out_trade_no
    self.origin&.payment_entity_no
  end

  # https://github.com/jasl/wx_pay
  # https://pay.weixin.qq.com/wiki/doc/api/native.php?chapter=9_4
  def invoke_refund
    params = {
      # 商户系统内部的退款单号，商户系统内部唯一，同一退款单号多次请求只退一笔
      out_refund_no: self.refund_uuid,
      # out_trade_no: out_trade_no, # 与transaction_id 二选一
      total_fee: (refunded_payment.total_amount * 100).to_i,
      refund_fee: (refund_price * 100).to_i,
      transaction_id: transaction_id
    }

    begin
      self.start_refund!
      result = WxPay::Service.invoke_refund(params)
      if result['result_code'] == 'SUCCESS'
        self.do_refund!
      else
        self.refund_failed!( note:result['result_code'])
      end
    rescue StandardError => e
      result = e.message
      self.refund_failed!( note: result )
    end
    result
  end
  def refund_query
    params = {
      out_refund_no: self.refund_uuid
    }
    result = WxPay::Service.refund_query(params)
  end

end
