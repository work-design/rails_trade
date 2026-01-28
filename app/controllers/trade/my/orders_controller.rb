module Trade
  class My::OrdersController < My::BaseController
    before_action :set_order, only: [
      :edit, :update, :destroy, :actions,
      :refund, :finish, :payment_types, :payment_wxpay, :payment_pending, :payment_confirm, :payment_frozen, :wait, :cancel, :wxpay_pc_pay, :package
    ]
    before_action :set_cart, only: [:cart, :cart_create]
    before_action :set_new_order, only: [:new, :create, :blank, :trial, :add]
    before_action :state_skip_back, only: [:cart]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:id, :payment_type, :payment_status, :state, :uuid)

      @orders = current_user.orders
                            .includes(:payment_strategy, :items, :payment_orders, address: :area, from_address: :area)
                            .default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
    end

    def show
      @order = Order.find(params[:id])

      if @order.user_id == current_user.id
        render 'show'
      elsif current_user.members.pluck(:organ_id).include? @order.organ_id
        redirect_to({ controller: 'trade/admin/orders', action: 'show', id: @order.id, host: @order.organ.admin_host }, allow_other_host: true)
      else
        render 'err_not_found'
      end
    end

    def cart
    end

    def cart_create
      @order = @cart.generate_order!
    end

    def trial
    end

    def payment_types
      @order.init_wallet_payments
      if support_wxpay?
        @wxpay_order = @order.init_wxpay_payment(
          state: 'pending',
          payee: current_payee,
          wechat_user: current_wechat_user,
          ip: request.remote_ip
        )
      end
    end

    def payment_wxpay
      unless request.variant.any?(:mini_program)
        @wxpay_order = @order.init_wxpay_payment(
          state: 'pending',
          payee: current_payee,
          wechat_user: current_wechat_user,
          ip: request.remote_ip
        )
      end
    end

    def payment_pending
      @order.batch_pending_payments(payment_params)
      @order.init_wallet_payments
      if support_wxpay?
        @wxpay_order = @order.init_wxpay_payment(
          state: 'pending',
          payee: current_payee,
          wechat_user: current_wechat_user,
          ip: request.remote_ip
        )
      end
    end

    def payment_confirm
      @order.batch_pending_payments(payment_params)
      if params['commit']
        @order.confirm!
      else
        @order.init_wallet_payments
        if support_wxpay?
          @order.init_wxpay_payment(
            state: 'pending',
            payee: current_payee,
            wechat_user: current_wechat_user,
            ip: request.remote_ip
          )
        end
      end
    end

    def payment_frozen
      if @order.items.map(&:good_type).exclude?('Trade::Advance') && @order.can_pay?
        @order.wallets.includes(:wallet_template).where(wallet_template_id: @order.wallet_codes).each do |wallet|
          @order.payments.build(type: 'Trade::WalletPayment', wallet_id: wallet.id)
        end
        if @order.lawful_wallet && @order.lawful_wallet.amount > @order.amount
          @order.lawful_wallet.wallet_frozens.build
          @order.payments.build(type: 'Trade::WalletPayment', wallet_id: @order.lawful_wallet.id)
        end
      end

      if @order.can_pay?
        set_wxpay
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
      @order = current_user.orders.find(params[:id])
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

    def payment_params
      params.fetch(:order, {}).permit(
        payment_orders_attributes: [
          :payment_amount,
          :order_amount,
          :state,
          payment: [
            :type,
            :wallet_id
          ]
        ]
      )
    end

    def support_wxpay?
      defined?(RailsWechat) &&
        request.variant.include?(:wechat) &&
        request.variant.exclude?(:work_wechat) &&
        current_payee &&
        current_wechat_user
    end

    def set_wxpay

    end

  end
end
