module Trade
  class Advance < ApplicationRecord
    include RailsTrade::Good
    include RailsTrade::Advance
  end
end
