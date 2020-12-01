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
      key: app.key,
      apiclient_cert: OpenSSL::X509::Certificate.new(app.apiclient_cert),
      apiclient_key: OpenSSL::PKey::RSA.new(app.apiclient_key)
    }

    begin
      result = WxPay::Service.invoke_refund(_params, options)
    rescue StandardError => e
      result = {}
      result['return_code'] = e.message.truncate(225)
    ensure
      store_refund_result(result)
    end

    self
  end

  def store_refund_result(result = {})
    return if state == 'completed'

    if result['return_code'] == 'SUCCESS'
      self.state = 'completed'
      order.payment_status = 'refunded'
      self.refunded_at = Time.current
    else
      self.state = 'failed'
      self.comment = result['return_code']
    end

    self.class.transaction do
      self.save!
      order.save!
    end
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

    result = WxPay::Service.refund_query(params, options)

    store_refund_result(result)
  end

end
