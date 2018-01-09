class SinglePromoteCharge < PromoteCharge

  def final_price(amount)
    (price * amount).round(2)
  end

end
