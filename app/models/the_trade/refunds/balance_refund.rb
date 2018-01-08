class BalanceRefund < Refund
  def do_refund(params = {})
    return unless can_refund?

    order = self.order
    refunded_amount = 0
    self.class.transaction do
      # 1. Refund to app_user_balances
       # .includes(:source, app_user_balance: [:app_user, :balance_rule])
      order.app_user_balance_payments.each do |payment|
        balance = payment.app_user_balance
        raise ActiveRecord::Rollback,
          "Your balance are refunding, please try later." if balance.pending?

        available_refund_amount = order.refund_price - refunded_amount

        if available_refund_amount >= payment.price
          available_refund_amount = payment.price
        end

        if available_refund_amount < 0
          available_refund_amount = 0
        end
        balance_price = if balance.usable?
                          balance.price + available_refund_amount
                        else
                          available_refund_amount
                        end
        balance.update_attributes(
          price:          balance_price,
          status:         'usable')

        refunded_amount += available_refund_amount
        payment.refunded!

        break if refunded_amount == order.refund_price
      end

      # 2. Update payments table status
      order.payments.each do |payment|
        payment.pay_status = 'REFUNDED'
      end

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
