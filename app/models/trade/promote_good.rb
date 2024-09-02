module Trade
  class PromoteGood < ApplicationRecord
    include Model::PromoteGood
    if defined? RailsCrm
      include Crm::Ext::Maintainable
    end
  end
end
