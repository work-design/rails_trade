module RailsTrade::PromoteCharge::FinalPromoteCharge

  def final_price(amount = nil)
    parameter.round(2)
  end

end
