module Trade
  class Our::OrdersController < My::OrdersController

    def index
      q_params = {}
      q_params.merge! params.permit(:id, :payment_type, :payment_status, :state)

      @orders = current_client.organ.member_orders.includes(:items).default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_order
      @order = current_client.organ.member_orders.find(params[:id])
    end

  end
end
