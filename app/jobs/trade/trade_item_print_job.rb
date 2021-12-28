module Trade
  class TradeItemPrintJob < ApplicationJob

    def perform(trade_item)
      trade_item.print
    end

  end
end
