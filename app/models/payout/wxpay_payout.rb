class WxpayPayout < Payout
  include RailsTrade::Payout::WxpayPayout
end unless defined? WxpayPayout
