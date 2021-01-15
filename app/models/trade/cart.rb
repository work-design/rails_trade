module Trade
  class Cart < ApplicationRecord
    include Model::Cart
    include Model::Amount
  end
end
