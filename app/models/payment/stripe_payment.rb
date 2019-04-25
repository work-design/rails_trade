class StripePayment < Payment
  include RailsTrade::Payment::StripePayment
end unless defined? StripePayment
