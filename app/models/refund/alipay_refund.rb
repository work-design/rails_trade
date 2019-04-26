class AlipayRefund < Refund
  include RailsTrade::Refund::AlipayRefund
end unless defined? AlipayRefund
