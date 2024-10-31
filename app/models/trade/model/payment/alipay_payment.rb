module Trade
  module Model::Payment::AlipayPayment
    extend ActiveSupport::Concern

    included do
      belongs_to :app, class_name: 'Alipay::App', foreign_key: :appid, primary_key: :appid, optional: true

      has_many :refunds, class_name: 'AlipayRefund', foreign_key: :payment_id

      validates :payment_uuid, presence: true, uniqueness: { scope: :type }
    end

    def assign_detail(params)
      self.buyer_identifier = params['buyer_login_id']
      self.pay_status = params['trade_status']

      self.total_amount = params['total_amount']
      self.income_amount = params['receipt_amount']

      self.notified_at = params['send_pay_date']

      self.seller_identifier = params['store_id'].to_s + params['terminal_id'].to_s
    end

    def micro_pay!(auth_code:, scene: 'bar_code', **options)
      app.api.trade_pay(
        out_trade_no: uuid,
        total_amount: total_amount.to_s,
        subject: good_desc,
        auth_code: auth_code,
        scene: scene
      )
    end

    def alipay_prepay
      app.api.trade_app_pay_params(
        subject: self.subject,
        out_trade_no: self.uuid,
        total_amount: self.total_amount.to_s
      )
    end

    def url(return_url: url_helpers.wait_my_order_url(self.id), notify_url: url_helpers.alipay_notify_payments_url)
      Alipay::Service.trade_page_pay(
        { subject: subject, out_trade_no: uuid, total_amount: amount.to_s },
        { return_url: return_url, notify_url: notify_url }
      )
    end

    #  result['trade_no']
    def result
      return self if self.payment_status == 'all_paid'

      result = app.api.trade_query out_trade_no: self.uuid
      result = JSON.parse(result)
      result = result['alipay_trade_query_response']

      if result['trade_status'] == 'TRADE_SUCCESS'
        self.assign_detail(result)
      else
        errors.add :base, result['msg']
        logger.error "Alipay: #{self.errors.full_messages.join(', ')}"
      end
    end

  end
end
