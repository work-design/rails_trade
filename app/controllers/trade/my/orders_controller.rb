module Trade
  class My::OrdersController < My::BaseController
    before_action :set_order, only: [
      :show, :edit, :update, :refund, :payment_types, :payment_type, :wait, :destroy, :cancel,
      :paypal_pay, :stripe_pay, :alipay_pay, :paypal_execute, :wxpay_pay, :wxpay_pc_pay,
      :package
    ]
    before_action :set_cart, only: [:cart]
    before_action :set_new_order, only: [:blank, :trial, :add, :create]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! client_params
      q_params.merge! params.permit(:id, :payment_type, :payment_status, :state)

      @orders = Order.includes(:payment_strategy, :items, :payment_orders, address: :area, from_address: :area, maintain: :member).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def new
      @order = current_user.orders.build(current_cart_id: params[:current_cart_id])
    end

    def cart
      @order = current_user.orders.build(current_cart_id: params[:current_cart_id])
    end

    def trial
    end

    def add
      @order.valid?
      @order.sum_amount
    end

    def create
      if @order.save
        render 'create'
      else
        render :new, locals: { model: @order }, status: :unprocessable_entity
      end
    end

    # todo part paid case
    def wait
      if @order.all_paid?
        render 'show'
      else
        render 'wait'
      end
    end

    def payment_types
      if @order.items.map(&:good_type).exclude?('Trade::Advance') && @order.can_pay?
        @order.wallets.where(wallet_template_id: @order.wallet_codes).each do |wallet|
          @order.payments.build(type: 'Trade::WalletPayment', wallet_id: wallet.id)
        end
      end
    end

    # https://pay.weixin.qq.com/wiki/doc/api/native.php?chapter=6_5
    # 二维码有效期为2小时
    def wxpay_pc_pay
      @wxpay_order = @order.native_order(current_wechat_app)

      if @wxpay_order['code'].present? || @wxpay_order.blank?
        render 'wxpay_pay_err', status: :unprocessable_entity
      else
        @image_url = QrcodeHelper.data_url @wxpay_order['code_url']
        render 'wxpay_pc_pay'
      end
    end

    def refund
      @order.apply_for_refund
    end

    def package
      @order.package
    end

    def cancel
      @order.state = 'canceled'
      @order.save
    end

    private
    def current_wechat_app
      if params[:appid]
        Wechat::App.find_by appid: params[:appid]
      else
        super
      end
    end

    def set_cart
      @cart = Cart.find_by id: params[:current_cart_id]
    end

    def set_order
      @order = Order.find(params[:id])
    end

    def set_new_order
      @order = current_user.orders.build(order_params)
    end

    def set_payment_strategies
      @payment_strategies = PaymentStrategy.default_where(default_ancestors_params)
    end

    def order_params
      p = params.fetch(:order, {}).permit(
        :quantity,
        :payment_id,
        :payment_type,
        :address_id,
        :from_address_id,
        :payment_strategy_id,
        :note,
        :uuid,
        :current_cart_id,
        items_attributes: {},
        payment_orders_attributes: {}
      )
      p.merge! default_form_params
    end

  end
end
