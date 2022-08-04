module Trade
  class Order < ApplicationRecord
    include Model::Order
    include Model::Amount
  end
end
