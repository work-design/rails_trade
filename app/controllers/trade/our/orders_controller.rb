module Trade
  class Our::OrdersController < My::OrdersController
    before_action :set_order, only: [:show]

    def index
      q_params = {}
      q_params.merge! params.permit(:id, :payment_type, :payment_status, :state)

      @orders = current_member.orders.includes(:trade_items).default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_order
      @order = current_member.orders.find(params[:id])
    end

    def order_params
      params.fetch(:order, {}).permit(
        :quantity,
        :payment_id,
        :payment_type,
        :address_id,
        :invoice_address_id,
        :note,
        trade_items_attributes: {}
      )
    end

  end
end
