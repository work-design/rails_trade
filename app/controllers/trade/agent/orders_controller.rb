module Trade
  class Agent::OrdersController < My::OrdersController

    def index
      @orders = current_member.agent_orders.order(id: :desc).page(params[:page])
    end

    private
    def set_new_order
      @order = current_member.agent_orders.build(order_params)
    end

    def set_order
      @order = Order.find(params[:id])
    end

  end
end

