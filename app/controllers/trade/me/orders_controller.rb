module Trade
  class Me::OrdersController < My::OrdersController

    def index
      q_params = {
        member_id: current_member.id
      }
      q_params.merge! params.permit(:id, :payment_type, :payment_status, :state)

      @orders = current_user.orders.includes(:trade_items).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def set_order
      @order = Order.find(params[:id])
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

    def self.local_prefixes
      [controller_path, 'trade/me/base', 'me']
    end

  end
end
