module Trade
  class PromoteGood < ApplicationRecord
    include Model::PromoteGood
    include Crm::Ext::Maintainable if defined? RailsCrm
  end
end
