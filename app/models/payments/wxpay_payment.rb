class WxpayPayment < Payment
  attr_accessor :openid, :spbill_create_ip

  def save_detail!(params)
    self.sign = params['sign']
    self.notified_at = params['time_end']
    self.order_uuid = params['out_trade_no']
    self.payment_uuid = params['transaction_id']
    self.pay_status = params['result_code']
    self.seller_identifier = params['mch_id']
    self.buyer_identifier = params['openid']
    self.total_amount = params['total_fee'].to_i / 100.0
    self.fee_amount = (self.total_amount * 0.60 / 100).round(2)
    self.save!
  end

  def wxpay_prepay
    return @wxpay_prepay if @wxpay_prepay
    params = {
      body: "订单编号: #{order.uuid}",
      out_trade_no: order.uuid,
      total_fee: (order.amount * 100).to_i,
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
