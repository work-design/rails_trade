module Trade
  class TradeItem < ApplicationRecord
    include Model::TradeItem
    include Rent::TradeItem
    include Job::Ext::Jobbed
  end
end
