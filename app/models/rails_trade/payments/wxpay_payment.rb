class WxpayPayment < Payment

  def assign_detail(params)
    self.sign = params['sign']
    self.notified_at = params['time_end']
    self.payment_uuid = params['transaction_id']
    self.pay_status = params['result_code']
    self.seller_identifier = params['mch_id']
    self.buyer_identifier = params['openid']
    self.total_amount = params['total_fee'].to_i / 100.0
    self.fee_amount = (self.total_amount * 0.60 / 100).round(2)
  end

end
