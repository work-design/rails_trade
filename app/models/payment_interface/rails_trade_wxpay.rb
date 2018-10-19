module RailsTradeWxpay
  extend ActiveSupport::Concern

  included do
    attr_accessor :openid, :spbill_create_ip
    delegate :url_helpers, to: 'Rails.application.routes'
  end

  def wxpay_prepay
    return @wxpay_prepay if @wxpay_prepay
    params = {
      body: "订单编号: #{self.uuid}",
      out_trade_no: self.uuid,
      total_fee: (self.amount * 100).to_i,
      spbill_create_ip: spbill_create_ip,
      notify_url: url_helpers.wxpay_notify_payments_url,
      trade_type: 'JSAPI',
      openid: openid
    }
    @wxpay_prepay = WxPay::Service.invoke_unifiedorder params
  end

  def wxpay_order
    return @wxpay_order if @wxpay_order

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
    params = {
      out_trade_no: self.uuid,
    }
    result = WxPay::Service.order_query params
    if result
      self.change_to_paid! type: 'WxpayPayment', params: result
    else
      self.errors.add :base, 'err'
    end
  end

end
