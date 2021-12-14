module Trade
  class Purchase < ApplicationRecord
    include Model::Good
    include Model::Purchase
  end
end
