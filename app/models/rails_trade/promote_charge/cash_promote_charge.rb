# 抵扣券，如果抵扣券金额大于总额，则为0
module RailsTrade::PromoteCharge::CashPromoteCharge

  def final_price(amount)
    if parameter.abs >= amount
      - amount
    else
      - parameter.abs
    end
  end

end
