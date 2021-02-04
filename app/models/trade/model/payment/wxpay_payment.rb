module Trade
  module Model::Payment::WxpayPayment

    def assign_detail(params)
      self.notified_at = params['success_time']
      self.pay_status = params['trade_state']
      self.seller_identifier = params['mchid']
      self.buyer_identifier = params.dig('payer', 'openid')
      self.buyer_bank = params['bank_type']
      self.total_amount = params.dig('amount', 'total').to_i / 100.0
      self.fee_amount = (self.total_amount * 0.60 / 100).round(2)
    end

  end
end
