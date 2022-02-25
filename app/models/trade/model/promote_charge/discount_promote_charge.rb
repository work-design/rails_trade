# 折扣价格
module Trade
  module Model::PromoteCharge::DiscountPromoteCharge

    # 用户输入参数可为
    # 正数的折扣，原价 * 折扣， 如 100 * 0.7， parameter 为0.7
    # 负数的折扣，原价 * （1+折扣），如 100 * (1-0.3), parameter 为 -0.3
    def final_price(amount)
      if parameter < 0 && parameter > -1
        (amount * parameter).round(2)
      elsif parameter > 0 && parameter < 1
        -(amount * (1 - parameter)).round(2)
      else
        amount
      end
    end

  end
end
