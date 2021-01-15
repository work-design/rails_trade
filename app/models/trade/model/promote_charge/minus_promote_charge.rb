# 满减/ 抵扣券
module Trade
  module Model::PromoteCharge::MinusPromoteCharge
    extend ActiveSupport::Concern

    included do
      validates :parameter, numericality: { less_than_or_equal_to: 0 }
    end

    # 如果抵扣券金额大于总额，则为0
    def final_price(amount)
      if parameter.abs >= amount
        - amount
      else
        - parameter.abs
      end
    end

  end
end
