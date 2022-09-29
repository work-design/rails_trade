module Trade
  module Model::Payment::WxpayPayment
    extend ActiveSupport::Concern

    included do
      belongs_to :app, class_name: 'Wechat::App', foreign_key: :seller_identifier, primary_key: :appid, optional: true

      has_many :refunds, class_name: 'WxpayRefund', foreign_key: :payment_id
    end

    def h5(app, payer_client_ip: '127.0.0.1')
      options = {
        mchid: app.mch_id,
        serial_no: app.serial_no,
        key: app.apiclient_key
      }
      params = {}
      params.merge! common_params(app)
      params.merge! scene_info: { payer_client_ip: payer_client_ip, h5_info: { type: 'Wap' } }

      logger.debug "\e[35m  wxpay params: #{params}  \e[0m"

      ::WxPay::Api.h5_order params, options
    end

    def native(app)
      options = {
        mchid: app.mch_id,
        serial_no: app.serial_no,
        key: app.apiclient_key
      }
      params = {}
      params.merge! common_params(app)

      logger.debug "\e[35m  wxpay params: #{params}  \e[0m"

      ::WxPay::Api.native_order params, options
    end

    def js_pay(app)
      prepay = common_prepay(app)
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

    def common_prepay(app)
      options = {
        mchid: app.mch_id,
        serial_no: app.serial_no,
        key: app.apiclient_key
      }
      params = {}
      params.merge! common_params(app)
      params.merge! payer: { openid: user.oauth_users.find_by(appid: app.appid)&.uid }
      logger.debug "\e[35m  wxpay params: #{params}  \e[0m"

      ::WxPay::Api.invoke_unifiedorder params, options
    end

    def common_params(app)
      {
        appid: app.appid,
        mchid: app.mch_id,
        description: "支付编号: #{payment_uuid}",
        out_trade_no: payment_uuid,
        notify_url: Rails.application.routes.url_for(host: app.host, controller: 'trade/payments', action: 'wxpay_notify'),
        amount: {
          total: (self.total_amount * 100).to_i,
          currency: 'CNY'
        }
      }
    end

    def assign_detail(params)
      self.notified_at = params['success_time']
      self.pay_status = params['trade_state']
      self.buyer_identifier = params.dig('payer', 'openid')
      self.buyer_bank = params['bank_type']
      self.total_amount = params.dig('amount', 'total').to_i / 100.0
      self.extra = params
      self.fee_amount = (self.total_amount * 0.60 / 100).round(2)
    end

    def result
      #return self if self.payment_status == 'all_paid'
      options = {
        mchid: app.mch_id,
        serial_no: app.serial_no,
        key: app.apiclient_key
      }
      params = {
        mchid: app.mch_id,
        out_trade_no: uuid
      }

      begin
        result = WxPay::Api.order_query params, options
      rescue #todo only net errr
        result = { 'err_code_des' => 'network error' }
      end
      logger.debug "\e[35m  wxpay result: #{result}  \e[0m"

      if result['trade_state'] == 'SUCCESS'
        self.assign_detail result
        self.confirm!
      else
        self.errors.add :base, result['trade_state_desc'] || result['err_code_des']
      end
    end

  end
end
