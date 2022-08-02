module Trade
  class From::OrdersController < My::OrdersController
    before_action :set_order, only: [:show]
    before_action :set_new_order, only: [:new, :create]
    before_action :set_payment_strategies, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! params.permit(:id, :payment_type, :payment_status, :state)

      @orders = current_user.from_orders.includes(:trade_items).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def new
      @order.address_id ||= params[:address_id]
      @order.compute_promote
      @order.valid?

      if params[:commit].present? && @order.save
        render 'create_blank'
      else
        @order.trade_items.build
      end
    end

    def create
    end

    private
    def set_order
      @order = current_user.orders.find(params[:id])
    end

    def _prefixes
      super do |pres|
        if ['new', 'create'].include?(params[:action])
          pres + ['trade/admin/orders/_base']
        else
          pres
        end
      end
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
