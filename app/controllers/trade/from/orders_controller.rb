module Trade
  class From::OrdersController < My::OrdersController
    before_action :set_new_order, only: [:new, :create]
    before_action :set_payment_strategies, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:id, :payment_type, :payment_status, :state)

      @orders = current_user.from_orders.includes(:trade_items, :payment_strategy, :payment_orders, address: :area, from_address: :area).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def new
      @order.address_id ||= params[:address_id]
      @order.init_uuid
      @order.trade_items.build
    end

    def create
      @order.valid?
      @order.compute_promote
      init_payment_orders

      if params[:commit].present? && @order.save
        render 'create'
      else
        @order.trade_items.build
        render 'new'
      end
    end

    private
    def set_order
      @order = current_user.from_orders.find(params[:id])
    end

    def set_new_order
      @order = current_user.from_orders.build(order_params)
    end

    def init_payment_orders
      if @order.item_amount.to_d > 0
        p = @order.payment_orders.find(&->(i){ i.kind == 'item_amount' }) || @order.payment_orders.build(kind: 'item_amount')
        p.check_amount = @order.item_amount
      end
      if @order.payment_strategy&.from_pay && @order.overall_additional_amount.to_d > 0
        p = @order.payment_orders.find(&->(i){ i.kind == 'overall_additional_amount' }) || @order.payment_orders.build(kind: 'overall_additional_amount')
        p.check_amount = @order.overall_additional_amount
        p.user_id = @order.from_user_id
      end
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

  end
end
