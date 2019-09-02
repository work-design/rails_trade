class ApplePayment < Payment
  include RailsTrade::Payment::ApplePayment
end unless defined? ApplePayment
