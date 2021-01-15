module Trade
  class Advance < ApplicationRecord
    include Model::Good
    include Model::Advance
  end
end
