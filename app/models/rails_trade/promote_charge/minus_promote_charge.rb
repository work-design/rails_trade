module RailsTrade::PromoteCharge::MinusPromoteCharge
  extend ActiveSupport::Concern
  included do
    validates :parameter, numericality: { less_than_or_equal_to: 0 }
  end
  
  def final_price(amount = nil)
    - parameter.abs.round(2)
  end

end
