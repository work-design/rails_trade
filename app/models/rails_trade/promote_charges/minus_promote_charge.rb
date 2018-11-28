class MinusPromoteCharge < PromoteCharge

  def final_price(amount)
    (amount - parameter).round(2)
  end

end
