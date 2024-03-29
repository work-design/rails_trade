module Trade
  class Board::OrdersController < My::OrdersController
    before_action :set_order, only: [:show]

    def index
      q_params = {}
      q_params.merge! params.permit(:id, :payment_type, :payment_status, :state)

      @orders = current_user.orders.includes(:organ, :payment_strategy, :items, address: :area, from_address: :area, maintain: :member).default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_order
      @order = current_user.orders.find(params[:id])
    end

  end
end
