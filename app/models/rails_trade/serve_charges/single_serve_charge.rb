class SingleServeCharge < ServeCharge

  def final_price(amount)
    base_price.to_d + (price * amount)
  end

end
