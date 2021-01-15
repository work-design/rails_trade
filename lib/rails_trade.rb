# frozen_string_literal: true

require 'rails_trade/engine'
require 'rails_trade/config'
require 'rails_trade/apple_pay'

module Trade

  def self.use_relative_model_naming?
    true
  end

end
