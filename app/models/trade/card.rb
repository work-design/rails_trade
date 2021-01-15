module Trade
  class Card < ApplicationRecord
    include RailsTrade::Card
    include RailsTrade::Compute
  end
end
