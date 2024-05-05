# 前 n (1) 件指定价格（免费）
module Trade
  module Model::PromoteCharge::ForePromoteCharge

    #
    def final_price(amount, **options)
      -(amount - parameter)
    end

    def minors_amount
      minors.inject(0) do |sum, minor|
        sum + minor.parameter
      end
    end

  end
end
