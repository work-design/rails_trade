module Trade
  class OrderResetJob < ApplicationJob

    def perform
      Org::Organ.find_each do |organ|
        organ.reset_order_counters!
      end
    end

  end
end
