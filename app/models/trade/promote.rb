module Trade
  class Promote < ApplicationRecord
    include RailsTrade::Promote
    include RailsComExt::Sequence
  end
end
