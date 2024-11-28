module Trade
  class Admin::OrdersController < Admin::BaseController
    before_action :set_order, only: [
      :show, :edit, :update, :destroy, :actions,
      :refund, :payment_types, :payment_orders, :print_data, :print, :purchase, :package, :micro,
      :adjust_edit, :adjust_update, :desk_edit, :desk_update, :contact_edit
    ]
    before_action :set_new_order, only: [:new, :new_simple, :create]
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

    def purchase
      @purchase_order = Order.new(generate_mode: 'purchase')
    end

    def batch_paid
      Order.where(id: params[:ids].split(',')).each do |i|
        i.direct_paid!
      end
    end

    def batch_pay
      orders = Order.where(id: params[:ids].split(',')).map do |order|
        { order: order, order_amount: order.unreceived_amount, state: 'pending' }
      end

      @payment = ScanPayment.new(
        payment_orders_attributes: orders
      )
    end

    def new_simple
    end

    def create
      if params[:commit].present? && @order.save
        render 'create'
      elsif params[:button] == 'new'
        render 'new'
      elsif params[:button] == 'new_simple'
        render 'new_simple'
      else
        render 'create'
      end
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
      if auth_code.start_with?('25', '26', '27', '28', '29', '30', 'fp') && current_alipay_app
        @payment = @order.to_payment(type: 'Trade::AlipayPayment')
        @payment.appid = current_alipay_app.appid
      else
        @payment = @order.to_payment(type: 'Trade::ScanPayment')
        @payment.payee_app = current_payee.payee_apps.includes(:app).where(app: { type: ['Wechat::PublicApp', 'Wechat::PublicAgency'] }).take
      end
      @payment.micro_pay!(auth_code: auth_code, spbill_create_ip: request.remote_ip)
    end

    def package
      @order.package
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
      render json: @order.to_cpcl
    end

    def print
      if @order.organ.device
        @order.print
      else
        redirect_to controller: 'jia_bo/admin/device_organs' and return
      end
      head :no_content
    end

    def adjust_update
      if order_adjust_params['amount']
        @order.adjust_amount = @order.adjust_amount.to_d + order_adjust_params['amount'].to_d - @order.amount
      end

      @order.save
    end

    def desk_edit
      @desks = Space::Desk.default_where(default_params)
    end

    def desk_update
      @order.items.each do |i|
        i.update desk_id: params[:desk_id]
      end
    end

    def contact_edit
      @contacts = Crm::Contact.default_where(default_params)
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

    def current_alipay_app
      return @current_alipay_app if defined? @current_alipay_app
      @current_alipay_app = Alipay::App.default_where(default_params).take
    end

    def auth_code
      params[:result].split(',')[-1]
    end

    def _prefixes
      super do |pres|
        if ['cart', 'add', 'show'].include?(params[:action])
          pres + ["trade/my/orders/_#{params[:action]}", 'trade/my/orders/_base']
        else
          pres
        end
      end
    end

    def order_params
      _p = params.fetch(:order, {}).permit(
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
        :contact_id,
        items_attributes: [
          :good_type,
          :good_id,
          :good_name,
          :number,
          :unit_id,
          :weight,
          :volume,
          :note,
          :image,
          :amount,
          :single_price
        ],
        cart_promotes_attributes: [:promote_id]
      )
      _p.merge! default_form_params
    end

    def order_adjust_params
      params.fetch(:order, {}).permit(:amount)
    end

  end
end
