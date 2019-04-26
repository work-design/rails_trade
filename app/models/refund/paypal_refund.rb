class PaypalRefund < Refund
  include RailsTrade::Refund::PaypalRefund
end unless defined? PaypalRefund
