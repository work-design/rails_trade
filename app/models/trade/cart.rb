module Trade
  class Cart < ApplicationRecord
    include RailsTrade::Cart
    include RailsTrade::Amount
  end
end
