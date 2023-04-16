module Trade
  class ItemCleanJob < ApplicationJob

    def perform(item)
      item.update(status: 'expired') if ['init', 'checked', 'trial'].include?(item.status)
    end

  end
end
