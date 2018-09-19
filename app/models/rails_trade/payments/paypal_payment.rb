class PaypalPayment < Payment
  validates :payment_uuid, uniqueness: true

  def assign_detail(params)

  end

end
