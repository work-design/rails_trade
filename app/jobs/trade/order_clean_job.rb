module Trade
  class OrderCleanJob < ApplicationJob

    def perform
      Order.expired.where(state: ['init']).update(state: 'closed')
    end

  end
end
