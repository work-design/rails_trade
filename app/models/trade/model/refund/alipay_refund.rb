# 支付宝批次号只能当天有效
module Trade
  module Model::Refund::AlipayRefund

    def do_refund
      return unless can_refund?

      refund_params = {
        trade_no: payment.payment_uuid,
        refund_amount: self.total_amount.to_s,
        out_request_no: self.refund_uuid
      }
      res = payment.app.api.trade_refund(refund_params)

      if res['trade_no'].present?
        self.refund_uuid = res['trade_no']
        self.state = 'completed'
        self.refunded_at = Time.current
      else
        self.reason = "code: #{refund['code']}, msg: #{refund['msg']}"
        self.state = 'failed'
      end

      self.save
    end

  end
end
