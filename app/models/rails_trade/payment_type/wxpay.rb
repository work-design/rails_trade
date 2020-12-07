module RailsTrade::PaymentType::Wxpay

  def wxpay_prepay(trade_type: 'JSAPI', spbill_create_ip: '127.0.0.0', notify_url: url_helpers.wxpay_notify_payments_url, app:)
    options = {
      appid: app.appid,
      mch_id: app.mch_id,
      key: app.key
    }
    params = {
      body: "订单编号: #{self.uuid}",
      out_trade_no: self.uuid,
      total_fee: (self.remaining_amount * 100).to_i,
      spbill_create_ip: spbill_create_ip,
      notify_url: notify_url,
      trade_type: trade_type,
      openid: user.oauth_users.find_by(app_id: app.appid)&.uid
    }

    ::WxPay::Service.invoke_unifiedorder params, options
  end

  def wxpay_order(trade_type: 'JSAPI', app:, **opts)
    prepay = wxpay_prepay(trade_type: trade_type, app: app, **opts)
    options = {
      appid: app.appid,
      mch_id: app.mch_id,
      key: app.key
    }

    if prepay.success?
      params = {
        noncestr: prepay['nonce_str'],
        prepayid: prepay['prepay_id']
      }
      if trade_type == 'JSAPI'
        ::WxPay::Service.generate_js_pay_req params, options
      else
        ::WxPay::Service.generate_app_pay_req params, options
      end
    else
      prepay.except(:raw)
    end
  end

  def wxpay_result(app:)
    return self if self.payment_status == 'all_paid'
    options = {
      appid: app.appid,
      mch_id: app.mch_id,
      key: app.key
    }
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
