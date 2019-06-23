# 抵扣券，如果抵扣券金额大于总额，则为0
module RailsTrade::PromoteCharge::CashPromoteCharge

  def final_price(amount)
    if amount <= parameter.abs 
      0
    else
      (amount - parameter.abs).round(2)
    end
  end

end
