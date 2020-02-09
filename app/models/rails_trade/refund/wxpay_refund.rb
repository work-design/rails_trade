module RailsTrade::Refund::WxpayRefund

  def transaction_id
    refunded_payment&.payment_uuid
  end

  def out_trade_no
    self.origin&.payment_entity_no
  end

  def do_refund(params = {})
    _params = {
      out_refund_no: self.refund_uuid,
      total_fee: (payment.total_amount * 100).to_i,
      refund_fee: (total_amount * 100).to_i,
      transaction_id: self.payment.payment_uuid
    }

    begin
      result = WxPay::Service.invoke_refund(_params)
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

  def refund_query
    params = {
      out_refund_no: self.refund_uuid
    }
    WxPay::Service.refund_query(params)
  end

end
