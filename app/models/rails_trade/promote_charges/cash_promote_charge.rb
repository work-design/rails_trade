class CashPromoteCharge < PromoteCharge

  def final_price(amount)
    amount <= parameter ? 0 : (amount - parameter).round(2)
  end

end
