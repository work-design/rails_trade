module RailsTradeAlipay
  extend ActiveSupport::Concern
  include PaymentInterfaceBase

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
      self.change_to_paid! type: 'AlipayPayment', params: result
    else
      errors.add :base, result['msg']
    end
  end

end
