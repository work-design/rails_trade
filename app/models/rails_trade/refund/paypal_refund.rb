module RailsTrade::Refund::PaypalRefund

  def do_refund(params = {})
    return unless can_refund?
    sale = PayPal::SDK::REST::DataTypes::Sale.find(payment.payment_uuid)

    params = params.merge({
      amount: {
        total: self.total_amount.to_s(:rounded, precision: 2),
        currency: self.currency.upcase
      }
    })
    result = sale.refund(params)

    if result.success?
      self.state = 'completed'
    elsif result.error
      self.reason = result.error['message']
      self.state = 'failed'
    end

    result
  end

end
