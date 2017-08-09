module TheAlipay
  extend ActiveSupport::Concern

  included do
  end

  def create_alipay
    Alipay::Service.trade_app_pay_params subject: self.subject,
                                         out_trade_no: self.uuid,
                                         total_amount: self.amount.to_s
  end

  def subject
    order_items.map { |oi| oi.good.name }.join(', ')
  end

end
