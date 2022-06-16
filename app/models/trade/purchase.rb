module Trade
  class Purchase < ApplicationRecord
    include Ext::Good
    include Model::Purchase
  end
end
