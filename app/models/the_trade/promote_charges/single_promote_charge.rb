class SinglePromoteCharge < PromoteCharge

  def final_price(amount)
    price * amount
  end

end
