module Trade
  class StripePayment < Payment
    include Model::Payment::StripePayment
  end
end
