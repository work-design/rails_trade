module Trade
  class Admin::OrdersController < Admin::BaseController
    before_action :set_order, only: [
      :show, :payment_types, :edit, :update, :refund, :destroy,
      :payment_orders, :print_data, :package, :micro
    ]
    before_action :set_new_order, only: [:new, :create]
    before_action :set_user, only: [:user]
    before_action :set_cart, only: [:cart]
    before_action :set_payment_strategies, only: [:unpaid, :new, :create]
    skip_before_action :require_user, only: [:print_data] if whether_filter :require_user
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

      @orders = Order.includes(:user, :member, :member_organ, :payment_strategy, :payment_orders).default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
    end

    def unpaid
      q_params = {
        payment_status: ['unpaid', 'part_paid']
      }
      q_params.merge! default_params
      q_params.merge! params.permit(:id, :uuid, :member_id, :payment_status, :state, :payment_type, 'created_at-lte', 'created_at-gte')

      @orders = Order.includes(:user, :member, :member_organ, :payment_strategy, :payment_orders).default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
    end

    def payments
      q_params = {}
      q_params.merge! params.permit(:id, :payment_status, :uuid)

      @orders = Order.default_where(q_params).page(params[:page])
    end

    def new
      @order.items.build
    end

    def cart
      @order = Order.new(current_cart_id: params[:current_cart_id])
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
      if @order.items.map(&:good_type).exclude?('Trade::Advance') && @order.can_pay?
        @order.wallets.where(wallet_template_id: @order.wallet_codes).each do |wallet|
          @order.payments.build(type: 'Trade::WalletPayment', wallet_id: wallet.id)
        end
      end
    end

    def micro
      @payment = @order.to_payment
      @payment.app_payee = current_payee
      @payment.save
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

    def set_cart
      @cart = Cart.find params[:current_cart_id]
    end

    def set_payment_strategies
      @payment_strategies = PaymentStrategy.default_where(default_ancestors_params)
    end

    def _prefixes
      super do |pres|
        if ['add'].include?(params[:action])
          pres + ['trade/my/orders/_add', 'trade/my/orders']
        elsif ['payment_types'].include?(params[:action])
          pres + ['trade/my/orders/_payment_types', 'trade/my/orders/_base']
        elsif ['show'].include?(params[:action])
          pres + ['trade/my/orders/_show', 'trade/my/orders/_base']
        elsif ['cart'].include?(params[:action])
          pres + ['trade/my/orders/_cart', 'trade/my/orders/_base']
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
        :current_cart_id,
        items_attributes: [:organ_id, :good_type, :good_id, :good_name, :number, :weight, :volume, :note, :image, :amount],
        cart_promotes_attributes: [:promote_id]
      )
      p.merge! default_form_params
    end

  end
end
