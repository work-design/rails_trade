module Trade
  module PaymentType::Wxpay

    def wxpay_prepay(app)
      options = {
        mchid: app.mch_id,
        serial_no: app.serial_no,
        key: app.apiclient_key
      }
      params = {}
      params.merge! wxpay_common_params(app)
      params.merge! payer: { openid: user.oauth_users.find_by(appid: app.appid)&.uid }
      logger.debug "\e[35m  wxpay params: #{params}  \e[0m"

      ::WxPay::Api.invoke_unifiedorder params, options
    end

    def h5_order(app, payer_client_ip: '127.0.0.1')
      options = {
        mchid: app.mch_id,
        serial_no: app.serial_no,
        key: app.apiclient_key
      }
      params = {}
      params.merge! wxpay_common_params(app)
      params.merge! scene_info: { payer_client_ip: payer_client_ip, h5_info: { type: 'Wap' } }

      logger.debug "\e[35m  wxpay params: #{params}  \e[0m"

      ::WxPay::Api.h5_order params, options
    end

    def native_order(app)
      options = {
        mchid: app.mch_id,
        serial_no: app.serial_no,
        key: app.apiclient_key
      }
      params = {}
      params.merge! wxpay_common_params(app)

      logger.debug "\e[35m  wxpay params: #{params}  \e[0m"

      ::WxPay::Api.native_order params, options
    end

    def wxpay_common_params(app)
      {
        appid: app.appid,
        mchid: app.mch_id,
        description: "订单编号: #{self.uuid}",
        out_trade_no: self.uuid,
        notify_url: Rails.application.routes.url_for(host: app.host, controller: 'trade/payments', action: 'wxpay_notify'),
        amount: {
          total: (self.remaining_amount * 100).to_i,
          currency: 'CNY'
        }
      }
    end

    def wxpay_order(app)
      prepay = wxpay_prepay(app)
      options = {
        appid: app.appid,
        mchid: app.mch_id,
        key: app.apiclient_key
      }

      if prepay['prepay_id']
        params = {
          prepayid: prepay['prepay_id']
        }
        WxPay::Api.generate_js_pay_req params, options
      else
        prepay
      end
    end

  end
end
