require 'the_trade/engine'
require 'the_trade/config'

module TheTrade

  def self.buyer_class
    @buyer_class
  end

  def self.buyer_class=(buyer)
    if @buyer_class.name == buyer.name
      return
    elsif buyer.ancestors.include?(ActiveRecord::Base)
      @buyer_class = buyer
    elsif buyer.is_a?(Class)
      raise 'You can not include TheTradeBuyer more than once'
    else
      raise 'You must assign an ActiveRecord class'
    end
  end

end
