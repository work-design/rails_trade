module RailsTradeWxpay
  extend ActiveSupport::Concern

  included do
    attr_accessor :openid, :spbill_create_ip, :notify_url
    delegate :url_helpers, to: 'Rails.application.routes'
  end

  def wxpay_prepay(trade_type = 'JSAPI', options = {})
    params = {
      body: "订单编号: #{self.uuid}",
      out_trade_no: self.uuid,
      total_fee: (self.amount * 100).to_i,
      spbill_create_ip: spbill_create_ip,
      notify_url: self.notify_url || url_helpers.wxpay_notify_payments_url,
      trade_type: trade_type,
    }
    if options.key?(:openid)
      _openid = options[:openid]
    else
      _openid = openid
    end
    params.merge!(openid: _openid) if _openid
    WxPay::Service.invoke_unifiedorder params, options.dup
  end

  def wxpay_order(trade_type = 'JSAPI', options = {})
    prepay = wxpay_prepay(trade_type, options)

    return { return_code: prepay['return_code'], return_msg: prepay['return_msg'] } unless prepay.success?

    if prepay['result_code'] == 'SUCCESS'
      params = {
        noncestr: prepay['nonce_str'],
        prepayid: prepay['prepay_id']
      }
      if trade_type == 'JSAPI'
        WxPay::Service.generate_js_pay_req params, options.dup
      else
        WxPay::Service.generate_app_pay_req params, options.dup
      end
    elsif prepay['result_code'] == 'FAIL'
      {
        result_code: 'FAIL',
        err_code: prepay['err_code'],
        err_code_des: prepay['err_code_des']
      }
    end
  end

  def wxpay_result(options = {})
    return self if self.payment_status == 'all_paid'

    params = {
      out_trade_no: self.uuid,
    }
    begin
      result = WxPay::Service.order_query params, options
    rescue
      result = { 'err_code_des' => 'network error' }
    end

    if result['trade_state'] == 'SUCCESS'
      self.change_to_paid! type: 'WxpayPayment', payment_uuid: result['transaction_id'], params: result
    else
      self.errors.add :base, result['err_code_des']
    end
  end

end
