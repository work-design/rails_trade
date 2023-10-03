module Trade
  class Agent::OrdersController < My::OrdersController

    private
    def set_new_order
      #@order = current_member.agent_orders.build(order_params)
    end

  end
end

