class DiscountPromoteCharge < PromoteCharge
  # parameter: 参数

  def final_price(amount)
    (amount * parameter).round(2)
  end

end
