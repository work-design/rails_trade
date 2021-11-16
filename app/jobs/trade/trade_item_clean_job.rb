module Trade
  class TradeItemCleanJob < ApplicationJob

    def perform(trade_item)
      trade_item.destroy
    end

  end
end
