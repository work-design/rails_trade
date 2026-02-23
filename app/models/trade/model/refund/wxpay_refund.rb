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

    def do_refund(**options)
      params = {
        out_refund_no: self.refund_uuid,
        amount: {
          total: (payment.total_amount * 100).to_i,
          refund: (total_amount * 100).to_i,
          currency: 'CNY'
        },
        transaction_id: self.payment.payment_uuid
      }

      result = payment.payee_app.payee.api.invoke_refund(**params, **options)
      if result.is_a?(Hash)
        store_refund_result!(result)
      end
      result
    end

    def store_refund_result(result)
      if ['PROCESSING', 'SUCCESS'].include? result['status']
        self.state = 'completed'
        self.refunded_at = result['create_time'] || Time.current
      else
        self.state = 'failed'
        self.comment = result['return_code']
      end
      self.response = result
    end

    def store_refund_result!(result = {})
      store_refund_result(result)
      self.save
    end

    def refund_query
      return if state == 'completed'

      result = payment.payee_app.payee.api.refund_query(self.refund_uuid)
      store_refund_result!(result)
      result
    end

    def refund_query!
      refund_query
      save
    end

  end
end
