class PaypalRefund < Refund
  SALE = PayPal::SDK::REST::DataTypes::Sale

  validate :valid_sale_id

  def do_refund(params)
    return unless can_refund?
    sale = SALE.find(order.sale_id)

    params = params.merge({
      amount: {
        total: self.total_amount.to_s(:rounded, precision: 2),
        currency: self.currency.upcase
      }
    })
    result = sale.refund(params)

    order.payment_status = 'refunded'
    order.received_amount -= self.order_amount

    self.user_id = params[:user_id] if params[:user_id].present?

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

  def can_refund?
    self.init? && ['all_paid', 'part_paid', 'refunded'].include?(order.payment_status)
  end

  def valid_sale_id
    if order.sale_id.blank?
      self.errors.add :type, 'Can not refund through Paypal!'
    end
  end

end
