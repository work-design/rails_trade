module RailsTrade::PromoteCharge::MinusPromoteCharge

  def final_price(amount)
    (amount - parameter.abs).round(2)
  end

end
