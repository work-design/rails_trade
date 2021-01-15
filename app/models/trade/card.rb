module Trade
  class Card < ApplicationRecord
    include Model::Card
    include Model::Compute
  end
end
