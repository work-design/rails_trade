class StripeRefund < Refund
  include RailsTrade::Refund::StripeRefund
end unless defined? StripeRefund
