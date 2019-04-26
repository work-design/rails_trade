module RailsTrade::Ordering::Base
  
  def amount_money
    self.amount.to_money(self.currency)
  end

end
