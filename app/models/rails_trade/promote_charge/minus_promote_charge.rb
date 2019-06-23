module RailsTrade::PromoteCharge::MinusPromoteCharge

  def final_price(amount)
    - parameter.abs.round(2)
  end

end
