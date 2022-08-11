module Trade
  class In::OrdersController < In::BaseController
    before_action :set_order, only: [:show, :edit, :update, :refund, :destroy]
    skip_before_action :verify_authenticity_token, only: [:refresh]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:id, :uuid, :user_id, :member_id, :payment_status, :state, :payment_type)

      @orders = Order.includes(:user, :member, :member_organ).default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
    end

    def payments
      q_params = {}
      q_params.merge! params.permit(:id, :payment_status, :uuid)

      @orders = Order.default_where(q_params).page(params[:page])
    end

    def new
      @order = Order.new(current_cart_id: params[:current_cart_id])
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
        :weight,
        :state,
        :payment_id,
        :payment_type,
        :address_id,
        :amount,
        :note,
        items_attributes: [:deliver_on, :number, :note],
        cart_promotes_attributes: [:promote_id]
      )
      p.merge! default_form_params
    end

  end
end
