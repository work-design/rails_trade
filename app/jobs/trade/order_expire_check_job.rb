module Trade
  class OrderExpireCheckJob < ApplicationJob

    def perform(order)
      order.update(state: 'closed') if order.unpaid?
    end

  end
end
