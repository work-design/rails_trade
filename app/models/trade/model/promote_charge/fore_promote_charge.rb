# 前 n (1) 件指定价格（免费）
module Trade
  module Model::PromoteCharge::ForePromoteCharge

    #
    def final_price(amount)
      -(amount - parameter)
    end

    def xx

    end

  end
end
