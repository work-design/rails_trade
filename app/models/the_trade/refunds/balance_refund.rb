class BalanceRefund < Refund
  def do_refund(params = {})
    return unless can_refund?

    order = self.order
    refunded_amount = 0
    self.class.transaction do
      order.app_user_balance_payments
        .includes(:source, app_user_balance: [:app_user, :balance_rule])
        .each do |payment|
        balance = payment.app_user_balance
        balance.update_attributes(price: (balance.price + payment.price),
               status: 'usable')

        refunded_amount += payment.price
        payment.refunded!
      end
      order.update_attributes(
        received_amount: order.received_amount - refunded_amount,
        payment_status: :refunded)

      self.update_attributes(
                operator_id: params[:operator_id],
                state: 'completed',
                refunded_at: Time.now)
    end
  rescue Exception => e
    Rails.logger.fatal e.inspect
    self.update reason: 'failed'
  ensure
    self
  end
end
