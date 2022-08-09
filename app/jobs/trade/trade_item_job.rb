module Trade
  class TradeItemJob < ApplicationJob

    def perform(trade_item)
      trade_item.order_work
    end

  end
end
