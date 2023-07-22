module Trade
  class PromoteGoodUser < PromoteGood
    include Model::PromoteGood::PromoteGoodUser
    include Crm::Ext::Maintainable if defined? RailsCrm
  end
end
