module Trade
  class Panel::OrdersController < Panel::BaseController
    before_action :set_order, only: [:show, :edit, :update, :refund, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:id, :uuid, :user_id, :member_id, :payment_status, :state, :payment_type)

      @orders = Order.includes(:user, :member, :member_organ).where(organ_id: nil).default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
    end

    def refund
      @order.apply_for_refund
    end

    private
    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.fetch(:order, {}).permit(
        :state,
        :payment_id,
        :payment_type,
        :address_id,
        :invoice_address_id,
        :note,
        trade_items_attributes: [:deliver_on, :advance_price, :comment],
        trade_promotes_attributes: [:promote_id]
      )
    end

  end
end
