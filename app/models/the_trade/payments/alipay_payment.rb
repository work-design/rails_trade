class AlipayPayment < Payment

  def assign_detail(params)
    self.sign = params[:sign]
    self.notified_at = params[:notify_time]
    self.payment_uuid = params[:trade_no]
    self.pay_status = params[:trade_status]
    self.seller_identifier = params[:seller_id]
    self.buyer_identifier = params[:buyer_id]
    self.buyer_email = params[:buyer_email]
    self.total_amount = params[:total_fee]
    # self.refunded_at = params[:gmt_refund]
    # self.refund_status = params[:refund_status]
  end

end
