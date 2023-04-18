module Trade
  class My::OrdersController < My::BaseController
    before_action :set_order, only: [
      :show, :edit, :update, :destroy, :actions,
      :refund, :finish, :payment_types, :wait, :cancel, :wxpay_pc_pay, :package
    ]
    before_action :set_cart, only: [:cart]
    before_action :set_new_order, only: [:new, :create, :blank, :trial, :add, :create]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:id, :payment_type, :payment_status, :state, :uuid)

      @orders = current_user.orders.includes(:payment_strategy, :items, :payment_orders, address: :area, from_address: :area, maintain: :member).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def cart
      @order = current_user.orders.build(current_cart_id: params[:current_cart_id])
    end

    def trial
    end

    def add
      @order.valid?
    end

    def payment_types
      if @order.items.map(&:good_type).exclude?('Trade::Advance') && @order.can_pay?
        @order.wallets.where(wallet_template_id: @order.wallet_codes).each do |wallet|
          @order.payments.build(type: 'Trade::WalletPayment', wallet_id: wallet.id)
        end
        @order.payments.build(type: 'Trade::WalletPayment', wallet_id: @order.lawful_wallet.id) if @order.lawful_wallet
      end

      unless @order.all_paid?
        @payment = @order.to_payment
        #@payment.extra_params.merge! 'profit_sharing' => true
        @payment.user = current_user
        @payment.app_payee = current_payee

        if request.variant.include?(:wechat) && request.variant.exclude?(:work_wechat)
          @payment.buyer_identifier = current_wechat_user&.uid
          @wxpay_order = @payment.js_pay(payer_client_ip: request.remote_ip)
          logger.debug "\e[35m  #{@wxpay_order}  \e[0m"
        else
          @url = @payment.h5(payer_client_ip: request.remote_ip)
        end
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
    def set_cart
      @cart = Cart.find params[:current_cart_id]
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
