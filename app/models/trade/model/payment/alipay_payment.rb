module Trade
  module Model::Payment::AlipayPayment

    def assign_detail(params)
      self.buyer_identifier = params['buyer_login_id']
      self.pay_status = params['trade_status']

      self.total_amount = params['total_amount']
      self.income_amount = params['receipt_amount']

      self.notified_at = params['send_pay_date']

      self.seller_identifier = params['store_id'].to_s + params['terminal_id'].to_s
    end

  end
end
