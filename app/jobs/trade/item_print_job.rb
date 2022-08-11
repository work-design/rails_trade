module Trade
  class ItemPrintJob < ApplicationJob

    def perform(item)
      item.print
    end

  end
end
