module RailsTradeWxpay
  extend ActiveSupport::Concern

  included do
    attr_accessor :openid, :spbill_create_ip, :notify_url
    delegate :url_helpers, to: 'Rails.application.routes'
  end

  def wxpay_prepay(trade_type = 'JSAPI')
    return @wxpay_prepay if defined?(@wxpay_prepay)
    params = {
      body: "订单编号: #{self.uuid}",
      out_trade_no: self.uuid,
      total_fee: (self.amount * 100).to_i,
      spbill_create_ip: spbill_create_ip,
      notify_url: self.notify_url || url_helpers.wxpay_notify_payments_url,
      trade_type: trade_type,
      openid: openid
    }
    @wxpay_prepay = WxPay::Service.invoke_unifiedorder params
  end

  def wxpay_order
    return @wxpay_order if defined?(@wxpay_order)

    prepay = wxpay_prepay
    if prepay['result_code'] == 'SUCCESS'
      params = {
        noncestr: prepay['nonce_str'],
        prepayid: prepay['prepay_id']
      }
      @wxpay_order = WxPay::Service.generate_js_pay_req params
    elsif prepay['result_code'] == 'FAIL'
      @wxpay_order = {
        result_code: 'FAIL',
        err_code: prepay['err_code'],
        err_code_des: prepay['err_code_des']
      }
    else
      @wxpay_order = {}
    end
  end

  def wxpay_result
    return self if self.payment_status == 'all_paid'

    params = {
      out_trade_no: self.uuid,
    }
    begin
      result = WxPay::Service.order_query params
    rescue
      result = { 'err_code_des' => 'network error' }
    end

    if result['result_code'] == 'SUCCESS'
      self.change_to_paid! type: 'WxpayPayment', payment_uuid: result['transaction_id'], params: result
    else
      self.errors.add :base, result['err_code_des']
    end
  end

end
