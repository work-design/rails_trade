# 一口价
module RailsTrade::PromoteCharge::FinalPromoteCharge
  extend ActiveSupport::Concern
  included do
  end
  
  # 返回原价与一口价之间的差，负数。
  def final_price(amount)
    -(amount - parameter)
  end

end
