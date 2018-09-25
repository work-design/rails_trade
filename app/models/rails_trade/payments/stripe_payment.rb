class StripePayment < Payment
  validates :payment_uuid, uniqueness: true


end
