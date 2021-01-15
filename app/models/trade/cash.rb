module Trade
  class Cash < ApplicationRecord
    include RailsTrade::Cash
    include RailsTrade::Compute
  end
end
