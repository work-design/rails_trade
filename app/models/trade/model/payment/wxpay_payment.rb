module Trade
  module Model::Payment::WxpayPayment
    extend ActiveSupport::Concern

    included do
      belongs_to :payee, ->(o) { where(organ_id: o.organ_id) }, class_name: 'Wechat::Payee', foreign_key: :seller_identifier, primary_key: :appid, optional: true

      has_many :refunds, class_name: 'WxpayRefund', foreign_key: :payment_id
    end

    def h5(payee, payer_client_ip: '127.0.0.1')
      options = {
        mchid: payee.mch_id,
        serial_no: payee.serial_no,
        key: payee.apiclient_key
      }
      params = {}
      params.merge! common_params(payee)
      params.merge! scene_info: { payer_client_ip: payer_client_ip, h5_info: { type: 'Wap' } }

      logger.debug "\e[35m  wxpay params: #{params}  \e[0m"

      ::WxPay::Api.h5_order params, options
    end

    def native(payee)
      options = {
        mchid: payee.mch_id,
        serial_no: payee.serial_no,
        key: payee.apiclient_key
      }
      params = {}
      params.merge! common_params(payee)

      logger.debug "\e[35m  wxpay params: #{params}  \e[0m"

      ::WxPay::Api.native_order params, options
    end

    def js_pay(payee)
      prepay = common_prepay(payee)
      options = {
        appid: payee.appid,
        mchid: payee.mch_id,
        key: payee.apiclient_key
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

    def common_prepay(payee)
      options = {
        mchid: payee.mch_id,
        serial_no: payee.serial_no,
        key: payee.apiclient_key
      }
      params = {}
      params.merge! common_params(payee)
      params.merge! payer: { openid: user.oauth_users.find_by(appid: payee.appid)&.uid }
      logger.debug "\e[35m  wxpay params: #{params}  \e[0m"

      ::WxPay::Api.invoke_unifiedorder params, options
    end

    def common_params(payee)
      {
        appid: payee.appid,
        mchid: payee.mch_id,
        description: "支付编号: #{payment_uuid}",
        out_trade_no: payment_uuid,
        notify_url: Rails.application.routes.url_for(host: payee.domain, controller: 'trade/payments', action: 'wxpay_notify'),
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
      self.seller_identifier = params['mchid']
      self.buyer_bank = params['bank_type']
      self.total_amount = params.dig('amount', 'total').to_i / 100.0
      self.extra = params
      self.fee_amount = (self.total_amount * 0.60 / 100).round(2)
    end

    def result
      #return self if self.payment_status == 'all_paid'
      options = {
        mchid: payee.mch_id,
        serial_no: payee.serial_no,
        key: payee.apiclient_key
      }
      params = {
        mchid: payee.mch_id,
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
