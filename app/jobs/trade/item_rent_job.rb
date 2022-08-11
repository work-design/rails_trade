module Trade
  class ItemRentJob < ApplicationJob

    def perform(item, wait)
      item.compute(wait)
    end

    after_perform do |job|
      args = job.arguments
      args[0].compute_continue(args[1] + 1)
    end

  end
end
