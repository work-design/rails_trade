module Trade
  module Model::Payment::WxpayPayment
    extend ActiveSupport::Concern

    included do
      belongs_to :app_payee, class_name: 'Wechat::AppPayee', optional: true
      belongs_to :buyer, ->(o) { where(app_payee_id: o.app_payee_id) }, class_name: 'Wechat::Receiver', foreign_key: :buyer_identifier, primary_key: :account, optional: true

      has_many :refunds, class_name: 'WxpayRefund', foreign_key: :payment_id
    end

    def block
      params = {
        appid: app_payee.appid,
        transaction_id: payment_uuid,
        out_order_no: extra['out_trade_no'],
        receivers: [buyer.order_params],
        unfreeze_unsplit: false
      }
      r = app_payee.api.profit_share(params)
    end

    def profit_query
      r = app_payee.api.profit_query(payment_uuid)
    end

    def h5(payer_client_ip: '127.0.0.1')
      params = {}
      params.merge! common_params
      params.merge! scene_info: { payer_client_ip: payer_client_ip, h5_info: { type: 'Wap' } }

      r = app_payee.api.h5_order(debug: true, **params)
      logger.debug "\e[35m  h5: #{r}  \e[0m"
      r['h5_url']
    end

    def native
      params = {}
      params.merge! common_params

      app_payee.api.native_order(**params)
    end

    def js_pay(payer_client_ip: '127.0.0.1')
      return unless app_payee
      prepay = common_prepay

      if prepay['prepay_id']
        params = {
          prepayid: prepay['prepay_id']
        }
        params.merge! scene_info: { payer_client_ip: payer_client_ip }

        r = app_payee.api.generate_js_pay_req(params)
        logger.debug "\e[35m  h5: #{r}  \e[0m"
        r
      else
        prepay
      end
    end

    def common_prepay
      params = {}
      params.merge! common_params
      params.merge!(
        payer: { openid: buyer_identifier.presence || user.oauth_users.find_by(appid: app_payee.appid)&.uid },
        settle_info: { profit_sharing: extra_params['profit_sharing'].present? }
      )
      logger.debug "\e[35m  wxpay params: #{params}  \e[0m"

      app_payee.api.jsapi_order(**params)
    end

    def common_params
      {
        description: "支付编号: #{payment_uuid}",
        out_trade_no: payment_uuid,
        notify_url: Rails.application.routes.url_for(host: app_payee.domain, controller: 'trade/payments', action: 'wxpay_notify'),
        amount: {
          total: (self.total_amount * 100).to_i,
          currency: 'CNY'
        }
      }
    end

    def assign_detail(params)
      self.notified_at = params['success_time']
      self.pay_status = params['trade_state']
      self.verified = true if self.pay_status == 'SUCCESS'
      self.buyer_identifier = params.dig('payer', 'openid')
      self.seller_identifier = params['mchid']
      self.buyer_bank = params['bank_type']
      self.total_amount = params.dig('amount', 'total').to_i / 100.0
      self.extra = params
      self.fee_amount = (self.total_amount * 0.60 / 100).round(2)
    end

    def result
      params = {
        mchid: app_payee.payee.mch_id,
        out_trade_no: payment_uuid
      }

      begin
        result = app_payee.api.order_query(params)
      rescue #todo only net errr
        result = { 'err_code_des' => 'network error' }
      end
      logger.debug "\e[35m  wxpay result: #{result}  \e[0m"

      if result['trade_state'] == 'SUCCESS'
        self.confirm!(result)
      else
        self.errors.add :base, result['trade_state_desc'] || result['err_code_des']
      end
    end

    def get_app_payee
      Wechat::Payee.find_by(organ_id: organ_id, appid: extra['appid'], mch_id: seller_identifier)
    end

    def send_verify_notice
      broadcast_action_to(
        self,
        action: :update,
        target: 'order_result',
        partial: 'wxpay_success',
        locals: { organ_id: organ_id, payment: self }
      )
    end

  end
end
