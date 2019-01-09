class DiscountPromoteCharge < PromoteCharge
  # parameter: 参数

  def final_price(amount)
    if parameter < 0 && parameter > -1
      (amount * (1 + parameter)).round(2)
    elsif parameter > 0 && parameter < 1
      (amount * parameter).round(2)
    else
      amount
    end
  end

end
