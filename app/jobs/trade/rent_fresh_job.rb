module Trade
  class RentFreshJob < ApplicationJob

    def perform(item, next_at)
      item.compute_present_duration!(next_at)
    end

    after_perform do |job|
      args = job.arguments
      args[0].compute_later
    end

  end
end
