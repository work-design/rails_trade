module Trade
  class StripeMethod < PaymentMethod
    include Model::PaymentMethod::StripeMethod
  end
end
