module TheBalancePay
  extend ActiveSupport::Concern

  included do
  end

  def create_balance_pay(buyer)
    self.update payment_type: 'balance'
    BalancePayService.pay(buyer_id: buyer.id,
                          amount:   self.amount,
                          order_id: self.id)
  end

end
