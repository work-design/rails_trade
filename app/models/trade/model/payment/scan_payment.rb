module Trade
  module Model::Payment::ScanPayment
    extend ActiveSupport::Concern

    included do
      before_save :sync_from_wechat_user
    end

    def sync_from_wechat_user
      if wechat_user
        self.user_id = wechat_user.user_id
      end
    end

    def micro_pay!(auth_code:, spbill_create_ip:)
      opts = {
        out_trade_no: payment_uuid.presence || UidUtil.nsec_uuid('ScanPAY'),
        auth_code: auth_code,
        total_fee: (self.total_amount * 100).to_i,
        body: good_desc,
        spbill_create_ip: spbill_create_ip
      }

      r = payee_app.api.pay_micropay(**opts)
      if r['result_code'] == 'SUCCESS'
        confirm!(r)
      else
        logger.debug "\e[35m  scan pay result: #{r}  \e[0m"
      end
    end

    def assign_detail(params)
      self.payment_uuid = params['transaction_id']
      self.notified_at = params['time_end']
      self.pay_status = params['result_code']
      self.verified = true if self.pay_status == 'SUCCESS'
      self.buyer_identifier = params['openid']
      self.seller_identifier = params['sub_mch_id'].presence || params['mch_id']
      self.buyer_bank = params['bank_type']
      self.total_amount = params['total_fee'].to_i / 100.0
      self.currency = params['cash_fee_type']
      self.extra = params
    end

  end
end
