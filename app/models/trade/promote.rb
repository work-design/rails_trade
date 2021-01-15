module Trade
  class Promote < ApplicationRecord
    include Model::Promote
    include Com::Ext::Sequence
  end
end
