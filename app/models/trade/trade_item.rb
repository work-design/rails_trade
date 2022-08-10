module Trade
  class TradeItem < ApplicationRecord
    include Model::TradeItem
    include Job::Ext::Jobbed
  end
end
