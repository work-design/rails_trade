class CashPromoteCharge < PromoteCharge

  def final_price(amount)
    amount <= parameter.abs ? 0 : (amount - parameter.abs).round(2)
  end

end
