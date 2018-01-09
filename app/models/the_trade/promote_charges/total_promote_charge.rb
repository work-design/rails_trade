class TotalPromoteCharge < PromoteCharge

  def final_price(amount = nil)
    price.round(2)
  end

end
