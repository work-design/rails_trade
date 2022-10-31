module Trade
  class Cart < ApplicationRecord
    include Model::Cart
    include Factory::Model::Cart if defined? RailsFactory
  end
end
