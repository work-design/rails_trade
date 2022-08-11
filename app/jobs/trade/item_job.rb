module Trade
  class ItemJob < ApplicationJob

    def perform(item)
      item.order_work
    end

  end
end
