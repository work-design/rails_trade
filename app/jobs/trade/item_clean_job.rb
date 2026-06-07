module Trade
  class ItemCleanJob < ApplicationJob

    def perform
      Item.expired.carting.update(status: 'expired')
    end

  end
end
