class WxpayRefund < Refund
  include RailsTrade::Refund::WxpayRefund
end unless defined? WxpayRefund
