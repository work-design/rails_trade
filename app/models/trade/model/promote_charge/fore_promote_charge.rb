# 前 n (1) 件指定价格（免费）
module Trade
  module Model::PromoteCharge::ForePromoteCharge

    #
    def final_price(amount, **options)
      r = minors.inject(0) do |sum, minor|
        sum + minor.parameter
      end
      if parameter.present?
        r += parameter
        num = max
      else
        num = min
      end

      -((num * options[:unit_price]) - r)
    end

  end
end
