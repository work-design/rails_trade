class AlipayPayment < Payment

  def assign_detail(params)
    self.notified_at = params['notify_time']
    self.payment_uuid = params['trade_no']
    self.pay_status = params['trade_status']
    self.seller_identifier = params['seller_id']
    self.buyer_identifier = params['buyer_id']
    self.total_amount = params['total_amount']
  end

end
