module Trade
  class Cart < ApplicationRecord
    include Model::Cart
    include Model::Amount
    include Factory::Model::Cart if defined? RailsFactory
  end
end
