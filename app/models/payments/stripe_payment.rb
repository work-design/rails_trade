class PaypalPayment < Payment

  validates :payment_uuid, uniqueness: true



end
