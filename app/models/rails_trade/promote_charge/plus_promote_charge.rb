module RailsTrade::PromoteCharge::PlusPromoteCharge

  def final_price(amount)
    base_price + (amount * parameter).round(2)
  end

end
