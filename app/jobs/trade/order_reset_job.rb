module Trade
  class OrderResetJob < ApplicationJob
    include ActiveJob::Continuable

    def perform
      step :process, start: Org::Organ.first.id do |step|
        Org::Organ.find_each(start: step.cursor) do |organ|
          organ.reset_order_counters!
          step.set! organ.id
        end
      end
    end

  end
end
