# 一口价
module Trade
  module Model::PromoteCharge::FinalPromoteCharge

    # 返回原价与一口价之间的差，负数。
    def final_price(amount)
      -(amount - parameter)
    end

  end
end
