class StripePayment < Payment
  validates :payment_uuid, uniqueness: true


  def assign_detail(charge)
    self.payment_uuid = charge.id
    self.total_amount = Money.new(charge.amount, self.currency).to_d
    self.currency = charge.currency.upcase

    payment_order = stripe.payment_orders.build(order_id: self.id, check_amount: stripe.total_amount)

    Payment.transaction do
      payment_order.confirm!
      stripe.save!
    end
    stripe
  end

end
