module PaymentInterfaceBase
  extend ActiveSupport::Concern
  
  def amount_money
    self.amount.to_money(self.currency)
  end

end
