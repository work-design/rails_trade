module RailsTrade::ServeCharge::PlusServeCharge

  def final_price(amount)
    base_price.to_d + (amount * parameter).round(2)
  end

end
