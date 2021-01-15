module Trade
  class Order < ApplicationRecord
    include RailsTrade::Order
    include RailsTrade::Amount
  end
end
