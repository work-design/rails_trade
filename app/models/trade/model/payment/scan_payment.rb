module Trade
  module Model::Payment::ScanPayment

    def micro_pay!(auth_code:, spbill_create_ip:)
      opts = {
        out_trade_no: payment_uuid,
        auth_code: auth_code,
        total_fee: (self.total_amount * 100).to_i,
        body: "一餐之计-餐饮服务",
        spbill_create_ip: spbill_create_ip
      }

      r = app_payee.api.pay_micropay(**opts)
      if r['result_code'] == 'SUCCESS'
        confirm!(r)
      end
    end

    def assign_detail(params)
      self.payment_uuid = params['transaction_id']
      self.notified_at = params['time_end']
      self.pay_status = params['result_code']
      self.verified = true if self.pay_status == 'SUCCESS'
      self.buyer_identifier = params['openid']
      self.seller_identifier = params['mch_id']
      self.buyer_bank = params['bank_type']
      self.total_amount = params['total_fee'].to_i / 100.0
      self.currency = params['cash_fee_type']
      self.extra = params
    end

  end
end
