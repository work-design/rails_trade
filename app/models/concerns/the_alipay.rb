module TheAlipay
  extend ActiveSupport::Concern

  included do
    attr_accessor :approve_url, :return_url, :cancel_url, :paypal_payment
    delegate :url_helpers, to: 'Rails.application.routes'
  end

  def wxpay_result
    params = {
      out_trade_no: self.uuid,
    }
    WxPay::Service.order_query params
  end

end
