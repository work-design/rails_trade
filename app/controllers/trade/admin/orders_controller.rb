module Trade
  class Admin::OrdersController < Admin::BaseController
    before_action :set_order, only: [
      :show, :payment_types, :edit, :update, :refund, :destroy,
      :payment_orders, :print_data, :package
    ]
    before_action :set_new_order, only: [:new, :create]
    before_action :set_user, only: [:user]
    before_action :set_payment_strategies, only: [:unpaid]
    skip_before_action :require_login, only: [:print_data] if whether_filter :require_login
    skip_before_action :require_role, only: [:print_data] if whether_filter :require_role

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:id, :uuid, :user_id, :member_id, :payment_status, :state, :payment_type)

      @orders = Order.includes(:user, :member, :member_organ, :payment_strategy).default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
    end

    def user
      q_params = {
        user_id: params[:user_id]
      }
      q_params.merge! default_params
      q_params.merge! params.permit(:id, :uuid, :member_id, :payment_status, :state, :payment_type)

      @orders = Order.includes(:user, :member, :member_organ, :payment_strategy).default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
    end

    def unpaid
      q_params = {
        payment_status: ['unpaid', 'part_paid']
      }
      q_params.merge! default_params
      q_params.merge! params.permit(:id, :uuid, :member_id, :payment_status, :state, :payment_type)

      @orders = Order.includes(:user, :member, :member_organ, :payment_strategy).default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
    end

    def payments
      q_params = {}
      q_params.merge! params.permit(:id, :payment_status, :uuid)

      @orders = Order.default_where(q_params).page(params[:page])
    end

    def new
      @order.trade_items.build
    end

    def create
      @order.agent_id = current_member.id
      @order.compute_promote

      if params[:commit].present? && @order.save
        render 'create'
      else
        render 'new'
      end
    end

    def payment_types
    end

    def refund
      @order.apply_for_refund
    end

    def package
      @order.package
    end

    def payment_orders
      @payment_orders = @order.payment_orders
    end

    def payment_new
      @payment_order = PaymentOrder.new
      @payments = @order.pending_payments
    end

    def payment_create
      @payment_order = @order.payment_orders.build(payment_order_params)
      @order = @payment_order.order

      if @payment_order.save
        render 'create'
      else
        render 'create_fail'
      end
    end

    def payment_destroy
      if @payment_order.init?
        @payment_order.destroy
      end
    end

    def print_data
      render json: @order.to_cpcl.bytes
    end

    private
    def set_order
      @order = Order.find(params[:id])
    end

    def set_new_order
      @order = Order.new order_params
    end

    def set_user
      @user = Auth::User.find params[:user_id]
    end

    def set_payment_strategies
      @payment_strategies = PaymentStrategy.default_where(default_ancestors_params)
    end

    def _prefixes
      super do |pres|
        if ['add'].include?(params[:action])
          pres + ['trade/my/orders/_add', 'trade/my/orders']
        elsif ['payment_types'].include?(params[:action])
          pres + ['trade/my/orders/_payment_types']
        elsif ['show'].include?(params[:action])
          pres + ['trade/my/orders/_show', 'trade/my/orders/_base']
        else
          pres
        end
      end
    end

    def order_params
      p = params.fetch(:order, {}).permit(
        :state,
        :payment_id,
        :payment_type,
        :address_id,
        :from_address_id,
        :amount,
        :note,
        :payment_strategy_id,
        :collectable,
        trade_items_attributes: [:organ_id, :good_type, :good_id, :good_name, :number, :weight, :volume, :note, :image, :amount],
        cart_promotes_attributes: [:promote_id]
      )
      p.merge! default_form_params
    end

  end
end
