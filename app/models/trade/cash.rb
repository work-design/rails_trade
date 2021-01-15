module Trade
  class Cash < ApplicationRecord
    include Model::Cash
    include Model::Compute
  end
end
