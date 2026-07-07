module Trade
  class Panel::OrdersController < Panel::BaseController
    before_action :set_order, only: [:show, :edit, :update, :refund, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:id, :uuid, :user_id, :member_id, :payment_status, :state, :payment_type)

      @orders = Order.includes(:organ, :user, :member, :member_organ).default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
      @grouped_orders = @orders.group_by { |i| i.created_at.to_date }
    end

    def refund
      @order.apply_for_refund
    end

    private
    def set_order
      @order = Order.find(params[:id])
    end

    def filter_columns
      {
        'state' => { type: 'dropdown', default: true },
        'payment_status' => { type: 'dropdown', default: true },
        'uuid' => { type: 'search', default: true },
        'created_at' => 'datetime'
      }
    end

    def order_params
      params.fetch(:order, {}).permit(
        :state,
        :payment_id,
        :payment_type,
        :address_id,
        :invoice_address_id,
        :note,
        items_attributes: [:deliver_on, :advance_price, :comment],
        trade_promotes_attributes: [:promote_id]
      )
    end

  end
end
