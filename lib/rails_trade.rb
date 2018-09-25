require 'rails_data'
require 'rails_audit'
require 'rails_trade/engine'
require 'rails_trade/config'

module RailsTrade

  def self.buyer_class
    @buyer_class
  end

  def self.buyer_class=(buyer)
    if @buyer_class&.name == buyer.name
      return
    elsif buyer.ancestors.include?(ActiveRecord::Base)
      @buyer_class = buyer
    elsif buyer.is_a?(Class)
      raise 'You can not include RailsTradeBuyer more than once'
    else
      raise 'You must assign an ActiveRecord class'
    end
  end

end
