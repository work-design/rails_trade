class StripePayment < Payment
  validates :payment_uuid, uniqueness: true


  def assign_detail(charge)
    self.payment_uuid = charge.id
    self.total_amount = Money.new(charge.amount, self.currency).to_d
    self.currency = charge.currency.upcase
  end

end
