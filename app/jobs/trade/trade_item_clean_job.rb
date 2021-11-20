module Trade
  class TradeItemCleanJob < ApplicationJob

    def perform(trade_item)
      trade_item.destroy if ['init', 'checked'].include?(trade_item.status)
    end

  end
end
