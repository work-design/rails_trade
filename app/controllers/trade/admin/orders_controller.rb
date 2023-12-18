module Trade
  class Admin::OrdersController < Admin::BaseController
    before_action :set_order, only: [
      :show, :edit, :update, :destroy, :actions,
      :refund, :payment_types, :payment_orders, :print_data, :print, :package, :micro, :adjust_edit, :adjust_update
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

    def batch_paid
      Order.where(id: params[:ids].split(',')).each do |i|
        i.direct_paid!
      end
    end

    def new
      @order.items.build
    end

    def cart
      @order = Order.new(current_cart_id: params[:current_cart_id])
    end

    def payment_types
      if @order.items.map(&:good_type).exclude?('Trade::Advance') && @order.can_pay?
        @order.wallets.where(wallet_template_id: @order.wallet_codes).each do |wallet|
          @order.payments.build(type: 'Trade::WalletPayment', wallet_id: wallet.id)
        end
      end
    end

    def micro
      auth_code = params[:result].split(',')[-1]

      @payment = @order.to_payment(type: 'Trade::ScanPayment')
      @payment.payee_app = current_payee
      @payment.micro_pay!(auth_code: auth_code, spbill_create_ip: request.remote_ip)
    end

    def package
      @order.package
    end

    def payment_orders
      @payment_orders = @order.payment_orders
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

    def print
      if @order.organ.device
        @order.print
      else
        redirect_to controller: 'jia_bo/admin/device_organs' and return
      end
      head :no_content
    end

    def adjust_edit
    end

    def adjust_update
      if order_adjust_params['amount']
        @order.adjust_amount = @order.adjust_amount.to_d + order_adjust_params['amount'].to_d - @order.amount
      end

      @order.save
    end

    private
    def set_order
      @order = Order.where(default_params).find(params[:id])
    end

    def set_new_order
      @order = Order.new(order_params)
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
        if ['payment_types', 'cart', 'add'].include?(params[:action])
          pres + ["trade/my/orders/_#{params[:action]}", 'trade/my/orders/_base']
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

    def order_adjust_params
      params.fetch(:order, {}).permit(:amount)
    end

  end
end
