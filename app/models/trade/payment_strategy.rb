module Trade
  class PaymentStrategy < ApplicationRecord
    include RailsTrade::PaymentStrategy
  end
end
