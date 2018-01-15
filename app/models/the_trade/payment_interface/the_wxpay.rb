module TheWxpay
  extend ActiveSupport::Concern

  included do
    attr_accessor :openid, :spbill_create_ip
    delegate :url_helpers, to: 'Rails.application.routes'
  end

  def wxpay_result
    params = {
      out_trade_no: self.uuid,
    }
    WxPay::Service.order_query params
  end

  def wxpay_prepay
    return @wxpay_prepay if @wxpay_prepay
    params = {
      body: "订单编号: #{self.uuid}",
      out_trade_no: self.uuid,
      total_fee: (self.amount * 100).to_i,
      spbill_create_ip: spbill_create_ip,
      notify_url: "#{Settings.callback_host}/yifubao/wxpay_notify",
      trade_type: 'JSAPI',
      openid: openid
    }
    @wxpay_prepay = WxPay::Service.invoke_unifiedorder params
  end

  def pay_order
    return @pay_order if @pay_order

    prepay = wxpay_prepay
    if prepay['result_code'] == 'SUCCESS'
      params = {
        nonceStr: prepay['nonce_str'],
        package: 'prepay_id=' + prepay['prepay_id']
      }
      @pay_order = WxPay::Service.generate_js_pay_req params
    elsif prepay['result_code'] == 'FAIL'
      @pay_order = {
        result_code: 'FAIL',
        err_code: prepay['err_code'],
        err_code_des: prepay['err_code_des']
      }
    else
      @pay_order = {}
    end
  end


end
