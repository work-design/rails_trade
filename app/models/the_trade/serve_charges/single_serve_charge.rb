class SingleServeCharge < ServeCharge

  def final_price(amount)
    price * amount
  end

end
