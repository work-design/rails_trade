class BalanceRefund < Refund
  def do_refund(params = {})
    return unless can_refund?

    order = self.order
    refunded_amount = 0
    self.class.transaction do
      # 1. Refund to app_user_balances
      order.app_user_balance_payments
        .includes(:source, app_user_balance: [:app_user, :balance_rule])
        .each do |payment|
        balance = payment.app_user_balance
        available_refund_amount = order.refund_price - refunded_amount

        if available_refund_amount >= balance.price
          available_refund_amount = balance_price
        end

        if available_refund_amount < 0
          available_refund_amount = 0
        end

        balance.update_attributes(
          price: (balance.price + available_refund_amount),
          status: 'usable')

        refunded_amount += payment.price
        payment.refunded!

        break if refunded_amount == order.refund_price
      end

      # 2. Update payments table status
      #order.payments.each do |payment|
      #  payment.pay_status = 'REFUNDED'
      #end

      # 3. Update orders
      order.update_attributes(
        received_amount: order.received_amount - refunded_amount,
        payment_status: :refunded)

      self.update_attributes(
                operator_id: params[:operator_id],
                state:       'completed',
                refunded_at: Time.now)
    end
  rescue Exception => e
    Rails.logger.fatal e.inspect
    self.update reason: 'failed'
  ensure
    self
  end
end
