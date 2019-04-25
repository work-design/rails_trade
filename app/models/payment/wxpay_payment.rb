class WxpayPayment < Payment
  include RailsTrade::Payment::WxpayPayment
end unless defined? WxpayPayment
