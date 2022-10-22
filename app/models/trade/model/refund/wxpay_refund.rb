# 微信是同一个批次号未退款成功可重复申请
module Trade
  module Model::Refund::WxpayRefund
    extend ActiveSupport::Concern

    def transaction_id
      refunded_payment&.payment_uuid
    end

    def out_trade_no
      self.origin&.payment_entity_no
    end

    def do_refund
      _params = {
        out_refund_no: self.refund_uuid,
        amount: {
          total: (payment.total_amount * 100).to_i,
          refund: (total_amount * 100).to_i,
          currency: 'CNY'
        },
        transaction_id: self.payment.payment_uuid
      }

      begin
        result = payment.payee.api.invoke_refund(_params)
      rescue StandardError => e
        result = {}
        result['return_code'] = e.message.truncate(225)
      ensure
        store_refund_result!(result)
      end

      self
    end

    def store_refund_result!(result = {})
      if ['PROCESSING', 'SUCCESS'].include? result['status']
        self.state = 'completed'
        self.refunded_at = result['success_time']
      else
        self.state = 'failed'
        self.comment = result['return_code']
      end
      self.save
    end

    def refund_query
      return if state == 'completed'
      params = {
        out_refund_no: self.refund_uuid
      }

      result = payment.payee.api.refund_query(params)
      store_refund_result!(result)
    end

    def refund_query!
      refund_query
      save
    end

  end
end
