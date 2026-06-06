module Trade
  class Agent::OrdersController < Admin::OrdersController
    include Controller::Agent

    def index
      q_params = {}
      q_params.merge! params.permit(:payment_status, :state)

      @common_orders = current_member.agent_orders.default_where(q_params)
      set_count(q_params)
      @orders = @common_orders.order(id: :desc).page(params[:page])
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
