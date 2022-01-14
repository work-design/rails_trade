module Trade
  module Model::Payment::WxpayPayment
    extend ActiveSupport::Concern

    included do
      belongs_to :app, class_name: 'Wechat::App', foreign_key: :seller_identifier, primary_key: :appid, optional: true
    end

    def assign_detail(params)
      self.notified_at = params['success_time']
      self.pay_status = params['trade_state']
      self.seller_identifier = params['mchid']
      self.buyer_identifier = params.dig('payer', 'openid')
      self.buyer_bank = params['bank_type']
      self.total_amount = params.dig('amount', 'total').to_i / 100.0
      self.fee_amount = (self.total_amount * 0.60 / 100).round(2)
    end

    def wxpay_result
      #return self if self.payment_status == 'all_paid'
      options = {
        mchid: app.mch_id,
        serial_no: app.serial_no,
        key: app.apiclient_key
      }
      params = {
        mchid: app.mch_id,
        out_trade_no: self.payment_uuid,
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
