module Trade
  class TradeItemRentJob < ApplicationJob

    def perform(trade_item, wait)
      trade_item.compute(wait)
    end

    after_perform do |job|
      args = job.arguments
      args[0].compute_continue(args[1] + 1)
    end

  end
end
