class StripePayment < Payment

  def assign_detail(charge)
    self.payment_uuid = charge.id
    self.total_amount = Money.new(charge.amount, self.currency).to_d
    self.currency = charge.currency.upcase
  end

end
