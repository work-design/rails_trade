module Trade
  module Model::Payment::WxpayPayment
    extend ActiveSupport::Concern

    included do
      attribute :appid, :string

      belongs_to :payee_app, ->(o) { where(appid: o.appid) }, class_name: 'Wechat::PayeeApp', foreign_key: :seller_identifier, primary_key: :mch_id, optional: true
      belongs_to :buyer, ->(o) { where(app_payee_id: o.app_payee_id) }, class_name: 'Wechat::Receiver', foreign_key: :buyer_identifier, primary_key: :account, optional: true
      belongs_to :app, class_name: 'Wechat::App', foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :agency, class_name: 'Wechat::Agency', foreign_key: :appid, primary_key: :appid, optional: true

      has_many :refunds, class_name: 'WxpayRefund', foreign_key: :payment_id
    end

    def sync_ship
      (app || agency).api
    end

    def block
      params = {
        appid: appid,
        transaction_id: payment_uuid,
        out_order_no: extra['out_trade_no'],
        receivers: [buyer.order_params],
        unfreeze_unsplit: false
      }

      payee_app.api.profit_share(params)
    end

    def profit_query
      payee_app.api.profit_query(payment_uuid)
    end

    def h5(payer_client_ip: '127.0.0.1')
      params = {}
      params.merge! common_params
      params.merge! scene_info: { payer_client_ip: payer_client_ip, h5_info: { type: 'Wap' } }

      r = payee_app.api.h5_order(debug: true, **params)
      logger.debug "\e[35m  h5: #{r}  \e[0m"
      r['h5_url']
    end

    def native
      params = {}
      params.merge! common_params

      payee_app.api.native_order(**params)
    end

    def js_pay(**options)
      return unless payee_app
      prepay = common_prepay(**options)

      if prepay['prepay_id']
        r = payee_app.api.generate_js_pay_req(prepay_id: prepay['prepay_id'])
        logger.debug "\e[35m  js pay: #{r}  \e[0m"
        r
      else
        prepay
      end
    end

    def common_prepay(**options)
      params = {}
      params.merge! common_params
      params.merge!(
        payer: { openid: buyer_identifier.presence || user.oauth_users.find_by(appid: appid)&.uid },
        settle_info: { profit_sharing: extra_params['profit_sharing'].present? }
      )
      logger.debug "\e[35m  wxpay params: #{params}  \e[0m"

      payee_app.api.jsapi_order(**params)
    end

    def common_params
      {
        description: "支付编号: #{payment_uuid}",
        out_trade_no: payment_uuid,
        notify_url: Rails.application.routes.url_for(host: organ.domain, controller: 'trade/payments', action: 'wxpay_notify', mch_id: payee_app.mch_id),
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
      self.buyer_identifier = params.dig('payer', 'openid') || params.dig('payer', 'sub_openid')
      self.seller_identifier = params['mchid'] || params['sub_mchid']
      self.appid = params['appid'] || params['sub_appid']
      self.buyer_bank = params['bank_type']
      self.total_amount = params.dig('amount', 'total').to_i / 100.0
      self.extra = params
      self.fee_amount = (self.total_amount * 0.60 / 100).round(2)
    end

    def result
      params = {
        mchid: mch_id,
        out_trade_no: payment_uuid
      }

      begin
        result = payee_app.api.order_query(params)
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

    def send_verify_notice
      broadcast_action_to(
        self,
        action: :append,
        target: 'body',
        partial: 'visit',
        locals: { url: Rails.application.routes.url_for(controller: 'trade/my/wxpay_payments', action: 'show', id: self.id) }
      )
    end

  end
end
