module Trade
  class In::OrdersController < Admin::OrdersController
    include Controller::In

    def index
      q_params = {}
      q_params.merge! params.permit(:id, :uuid, :user_id, :member_id, :payment_status, :state, :payment_type)

      @orders = current_organ.orders.includes(:user, :member, :member_organ).default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
    end

    def payments
      q_params = {}
      q_params.merge! params.permit(:id, :payment_status, :uuid)

      @orders = Order.default_where(q_params).page(params[:page])
    end

    def refund
      @order.apply_for_refund
    end

    private
    def set_order
      @order = current_organ.orders.find(params[:id])
    end

    def set_new_order
      @order = current_organ.orders.build(order_params)
    end

    def order_params
      _p = params.fetch(:order, {}).permit(
        :organ_id,
        :weight,
        :quantity,
        :payment_id,
        :payment_type,
        :address_id,
        :invoice_address_id,
        :note,
        :generate_mode,
        :current_cart_id,
        items_attributes: {},
        item_promotes_attributes: {}
      )
      _p[:items_attributes].each do |_, v|
        v.merge! member_organ_id: current_organ.id
      end
      _p.merge! current_cart_id: params[:current_cart_id] if params[:current_cart_id]
      _p
    end

  end
end
