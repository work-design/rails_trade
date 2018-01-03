class PaypalRefund < Refund
  SALE = PayPal::SDK::REST::DataTypes::Sale

  def do_refund(params = {})
    return unless can_refund?
    sale = SALE.find(payment.payment_uuid)

    params = params.merge({
      amount: {
        total: self.refund_price.to_s(:rounded, precision: 2),
        currency: self.currency.upcase
      }
    })

    result = sale.refund(params)

    order.payment_status = 'refunded'
    self.operator_id = params[:operator_id]

    if result.success?
      self.state = 'completed'
      self.refunded_at = Time.now
      self.class.transaction do
        order.save!
        self.save!
      end
    elsif result.error
      self.update reason: result.error['message']
    end
    result
  end

end
