module Trade
  class Admin::OrdersController < Admin::BaseController
    before_action :set_order, only: [:show, :edit, :update, :refund, :destroy]
    skip_before_action :verify_authenticity_token, only: [:refresh]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:id, :uuid, :user_id, :member_id, :payment_status, :payment_type)

      @orders = Order.includes(:user).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def payments
      q_params = {}
      q_params.merge! params.permit(:id, :payment_status, :uuid)

      @orders = Order.default_where(q_params).page(params[:page])
    end

    def new
      @order = Order.new

      if params[:cart_item_id]
        @order.migrate_from_cart_item(params[:cart_item_id])
      else
        @order.migrate_from_cart_items
      end
    end

    def refresh
      @order = Order.new(buyer_id: params[:buyer_id])
      @order.assign_attributes order_params

      if params[:cart_item_id]
        cart_item = CartItem.find(params[:cart_item_id])
        cart_item.update extra: @order.extra
        @order.migrate_from_cart_item(params[:cart_item_id])
      else
        @order.migrate_from_cart_items
      end
    end

    def create
      @order = Order.new(order_params)

      if @order.save
        render 'create'
      else
        render 'new', locals: { model: @order }, status: :unprocessable_entity
      end
    end

    def refund
      @order.apply_for_refund
    end

    private
    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      p = params.fetch(:order, {}).permit(
        :quantity,
        :state,
        :payment_id,
        :payment_type,
        :address_id,
        :invoice_address_id,
        :amount,
        trade_items_attributes: [:deliver_on, :advance_price, :comment],
        trade_promotes_attributes: [:promote_id]
      )
      p.merge! default_form_params
    end

  end
end
