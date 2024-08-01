module Trade
  class In::HomeController < In::BaseController

    def index
      @orders_count = current_organ.organ_orders.count
    end

  end
end
