module TheAlipay
  extend ActiveSupport::Concern

  included do
  end

  def create_balnace_pay(buyer)
    self.update payment_type: 'balance'
    BalancePayService.pay(buyer_id: buyer.id,
                          amount:   self.amount,
                          order_id: self.id)
  end

  def create_alipay
    self.update payment_type: 'alipay'
    Alipay::Service.trade_app_pay_params(subject: self.subject, out_trade_no: self.uuid, total_amount: self.amount.to_s)
  end

  def create_alipay_url
    self.update payment_type: 'alipay'
    Alipay::Service.trade_page_pay subject: self.subject, out_trade_no: self.uuid, total_amount: self.amount.to_s
  end

  # 3 step: check result
  def alipay_result
    result = Alipay::Service.trade_query out_trade_no: self.uuid
    result = JSON.parse(result)
    result = result['alipay_trade_query_response']

    if result['trade_status'] == 'TRADE_SUCCESS'
      alipay = AlipayPayment.new
      alipay.payment_uuid = result['trade_no']
      alipay.buyer_identifier = result['buyer_user_id']
      alipay.total_amount = result['total_amount']
      alipay.income_amount = result['receipt_amount']
      alipay.notified_at = result['send_pay_date']

      payment_order = alipay.payment_orders.build(order_id: self.id, check_amount: alipay.total_amount)

      begin
        Payment.transaction do
          payment_order.confirm!
          alipay.save!
        end
        alipay
      rescue
        AlipayPayment.find_by(payment_uuid: result['trade_no'])
      end
    else
      errors.add :uuid, result['msg']
    end
  end

  def subject
    order_items.map { |oi| oi.good.name }.join(', ')
  end

end
