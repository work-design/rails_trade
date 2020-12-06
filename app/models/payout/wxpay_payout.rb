class WxpayPayout < Payout
  include RailsVip::Payout::WxpayPayout
end unless defined? WxpayPayout
