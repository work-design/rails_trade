require 'rails_data'
require 'rails_audit'
require 'rails_trade/engine'
require 'rails_trade/config'

module RailsTrade
  @buyer_classes = []

  class << self
    attr_accessor :buyer_classes
  end

end
