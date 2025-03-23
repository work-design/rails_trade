module Trade
  class OrderPrintJob < ApplicationJob

    def perform(order)
      order.print_to_prepare
    end

  end
end
