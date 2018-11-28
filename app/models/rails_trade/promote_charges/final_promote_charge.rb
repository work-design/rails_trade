class FinalPromoteCharge < PromoteCharge

  def final_price(amount = nil)
    parameter.round(2)
  end

end
