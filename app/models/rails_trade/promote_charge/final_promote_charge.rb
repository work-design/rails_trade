module RailsTrade::PromoteCharge::FinalPromoteCharge

  def final_price(amount = nil)
    -(amount - parameter.round(2))
  end

end
