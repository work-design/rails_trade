module RailsVip::Payout::WxpayPayout
  extend ActiveSupport::Concern

  included do
    attribute :payout_uuid, :string, default: -> { UidHelper.nsec_uuid('POT', separator: '') }
  end

  def do_pay
    p = {
      openid: self.account_num,
      amount: (self.requested_amount * 100).to_i,
      partner_trade_no: self.payout_uuid,
      check_name: 'NO_CHECK',
      desc: 'd',
      spbill_create_ip: '127.0.0.1'
    }

    r = WxPay::Service.invoke_transfer p
    result = r.dig(:raw, 'xml')
    if result['result_code'] == 'SUCCESS'
      self.update state: 'done'
    else
      self.update state: 'failed'
    end
  rescue
    self.update state: 'failed'
  end

end
