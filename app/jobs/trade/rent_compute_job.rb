module Trade
  class RentComputeJob < ApplicationJob

    def perform(rent, wait)
      rent.compute(wait)
    end

    after_perform do |job|
      args = job.arguments
      args[0].compute_continue(args[1] + 1)
    end

  end
end
