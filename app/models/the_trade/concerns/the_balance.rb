module TheBalance
  extend ActiveSupport::Concern

  def create_balance
    self.update payment_type: 'balance'
  end

  def create_balance_pay(buyer)
    self.update payment_type: 'balance'
    BalancePayService.pay(buyer_id: buyer.id,
                          amount:   self.amount,
                          order_id: self.id)
  end

  def balance_result
    usable_balances_sum = self.buyer.usable_balances_sum
    if usable_balances_sum < self.total_amount
      return "Your balances are not enough to pay your order!"
    end

    usable_balances = self.buyer.usable_balances
    left = 0
    usable_balances.each do |balance|
      left = balance.price - self.total_amount
      if left >= 0
        # pay by balance
        balance.price = left
        balance_payment = BalancePayment.new
        balance_payment.payment_uuid     = self.uuid
        balance_payment.buyer_identifier = self.buyer_id
        balance_payment.total_amount     = self.total_amount

        payment_order = balance_payment.payment_orders
                               .build(order_id: self.id,
                                      check_amount: balance.total_amount)

        Payment.transaction do
          balance.save!
          payment_order.confirm!
          balance_payment.save!
        end
      else
        break
      end
    end
  rescue
    BalancePayment.find_by(payment_uuid: self.uuid)
  end
end
