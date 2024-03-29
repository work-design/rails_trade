module Trade
  class Mem::OrdersController < My::OrdersController

    def index
      q_params = { organ_id: current_organ.id }
      q_params.merge! params.permit(:id, :uuid, :user_id, :member_id, :payment_status, :state, :payment_type)

      @orders = current_client.orders.includes(:member_organ).default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
    end

    def payments
      q_params = {}
      q_params.merge! params.permit(:id, :payment_status, :uuid)

      @orders = Order.default_where(q_params).page(params[:page])
    end

    def new
      @order = Order.new(current_cart_id: params[:current_cart_id])
    end

    def refund
      @order.apply_for_refund
    end

    private
    def set_order
      @order = current_client.orders.find(params[:id])
    end

    def set_new_order
      @order = current_client.orders.build(order_params)
    end

  end
end
