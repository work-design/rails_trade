# 微信是同一个批次号未退款成功可重复申请
module RailsTrade::Refund::WxpayRefund

  def transaction_id
    refunded_payment&.payment_uuid
  end

  def out_trade_no
    self.origin&.payment_entity_no
  end

  def do_refund(app:, **params)
    _params = {
      out_refund_no: self.refund_uuid,
      total_fee: (payment.total_amount * 100).to_i,
      refund_fee: (total_amount * 100).to_i,
      transaction_id: self.payment.payment_uuid
    }
    options = {
      appid: app.appid,
      mch_id: app.mch_id,
      key: app.key
    }
    result = WxPay::Service.invoke_refund(_params, options)
    binding.pry

    begin
      result = WxPay::Service.invoke_refund(_params, options)
      binding.pry
      if result['result_code'] == 'SUCCESS'
        self.state = 'completed'
        order.payment_status = 'refunded'
        self.refunded_at = Time.now
      else
        self.state = 'failed'
        self.comment = result['result_code']
      end
    rescue StandardError => e
      self.state = 'failed'
      self.comment = e.message.truncate(225)
    ensure
      self.class.transaction do
        self.save!
        order.save!
      end
    end
    self
  end

  def refund_query(app:)
    params = {
      out_refund_no: self.refund_uuid
    }
    options = {
      appid: app.appid,
      mch_id: app.mch_id,
      key: app.key
    }

    WxPay::Service.refund_query(params, options)
  end

end
