module RailsTrade::PaymentType::Alipay

  def alipay_prepay
    self.update payment_type: 'alipay'
    Alipay2::Service.trade_app_pay_params(subject: self.subject, out_trade_no: self.uuid, total_amount: self.amount.to_s)
  end

  def alipay_prepay_url
    self.update payment_type: 'alipay'
    Alipay2::Service.trade_page_pay subject: self.subject, out_trade_no: self.uuid, total_amount: self.amount.to_s
  end

  def alipay_result
    return self if self.payment_status == 'all_paid'

    result = Alipay2::Service.trade_query out_trade_no: self.uuid
    result = JSON.parse(result)
    result = result['alipay_trade_query_response']

    if result['trade_status'] == 'TRADE_SUCCESS'
      self.change_to_paid! type: 'AlipayPayment', payment_uuid: result['trade_no'], params: result
    else
      errors.add :base, result['msg']
      logger.error "Alipay: #{self.errors.full_messages.join(', ')}"
    end
  end

end
