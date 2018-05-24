require 'the_trade/engine'
require 'the_trade/config'

module TheTrade

  def self.buyer_class
    @buyer_class
  end

  def self.buyer_class=(buyer)
    if @buyer_class.is_a?(Class)
      raise 'You can not include TheTradeBuyer more than once'
    elsif buyer.ancestors.include?(ActiveRecord::Base)
      @buyer_class = buyer
    else
      raise 'You must assign an ActiveRecord class'
    end
  end

end
