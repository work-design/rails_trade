module Trade
  class Advance < ApplicationRecord
    include Ext::Good
    include Model::Advance
  end
end
