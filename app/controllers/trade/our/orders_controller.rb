module Trade
  class Our::OrdersController < My::OrdersController

    def index
      q_params = { organ_id: current_organ.id }
      q_params.merge! params.permit(:id, :uuid, :user_id, :member_id, :payment_status, :state, :payment_type)

      @orders = current_client.organ.member_orders.includes(:member_organ).default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
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

    def order_params
      p = params.fetch(:order, {}).permit(
        :weight,
        :quantity,
        :payment_id,
        :payment_type,
        :address_id,
        :invoice_address_id,
        :note,
        :current_cart_id,
        items_attributes: {},
        item_promotes_attributes: {}
      )
      p.merge! current_cart_id: params[:current_cart_id] if params[:current_cart_id]
      p.merge! default_form_params
      p
    end

    def current_payee
      return @current_payee if defined?(@current_payee)

      if params[:appid]
        @current_payee = current_organ_domain.app_payees.find_by(appid: params[:appid])
      elsif current_wechat_app
        @current_payee = current_wechat_app.app_payees.take
      else
        @current_payee = current_organ_domain.app_payees.take
      end

      logger.debug "\e[35m  Current Payee: #{@current_payee&.id}  \e[0m"
      @current_payee
    end

  end
end
