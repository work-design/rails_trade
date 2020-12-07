class CardRefund < Refund
  include RailsTrade::Refund::CardRefund
end unless defined? CardRefund
