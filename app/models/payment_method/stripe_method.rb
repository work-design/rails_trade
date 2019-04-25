class StripeMethod < PaymentMethod
  include RailsTrade::PaymentMethod::StripeMethod
end unless defined? StripeMethod
