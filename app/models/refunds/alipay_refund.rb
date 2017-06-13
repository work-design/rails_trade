class AlipayRefund < Refund

  def transaction_id
    refunded_payment&.payment_uuid
  end

  def invoke_refund
    Alipay::Service.refund_fastpay_by_platform_pwd_url(refund_params)
  end

  def can_renew_refund_uuid?
    self.init? && !refund_uuid.start_with?(Date.today.strftime('%Y%m%d'))
  end

  def refund_params
    {
      batch_no: refund_uuid,
      data: [
        {
          trade_no: transaction_id,
          amount: self.amount.to_s,
          reason: '业务退款'
        }
      ],
      notify_url: PAYMENT['callback_host'] + '/yifubao/alipay_refund'
    }
  end

end
