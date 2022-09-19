module Trade
  class RentClearJob < ApplicationJob

    def perform(rentable)
      rentable.clear_held
    end

  end
end
