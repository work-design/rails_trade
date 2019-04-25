class PaypalPayment < Payment
  include RailsTrade::Payment::PaypalPayment
end unless defined? PaypalPayment
