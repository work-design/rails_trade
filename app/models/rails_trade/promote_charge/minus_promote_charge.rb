module RailsTrade::PromoteCharge::MinusPromoteCharge

  def final_price(amount = nil)
    - parameter.abs.round(2)
  end

end
