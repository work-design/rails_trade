module Trade
  class My::PaymentsController < My::BaseController
    before_action :set_order, only: [:order_new, :order_create, :wxpay]
    before_action :set_new_payment_with_order, only: [:order_new, :order_create]
    before_action :set_payment_order, only: [:payment_order_new, :payment_order_create]
    before_action :set_new_payment_with_payment_order, only: [:payment_order_new, :payment_order_create]
    before_action :set_payment, only: [:show, :edit, :update, :destroy]
    before_action :set_new_payment, only: [:new, :create]

    def index
      @payments = current_user.payments.page(params[:page])
    end

    def order_new
      @payment.total_amount = @order.unreceived_amount
    end

    def order_create
      @payment.save
    end

    def payment_order_new
      @payment.total_amount = @payment_order.check_amount
    end

    def payment_order_create
      @payment_order.state = 'pending'
      @payment.save
    end

    def next
      if @order.payment_status == 'all_paid'
        render 'paid' and return
      end
      url = @payment.url(params)

      if @payment.errors.blank?
        render 'create', locals: { url: url }
      else
        render 'create', locals: { url: url_for(controller: 'orders') }
      end
    end

    def paypal_execute
      if @order.paypal_execute(params)
        flase.now[:notice] = "Order[#{@order.uuid}] placed successfully"
        render 'create', locals: { return_to: board_order_url(@order) }
      else
        flase.now[:notice] =  @order.error.inspect
        render 'create', locals: { return_to: board_orders_url }
      end
    end

    def wxpay
      @payment = @order.payments.build type: 'Trade::WxpayPayment', payment_uuid: @order.uuid, total_amount: @order.amount
      @payment.user = current_user
      @wxpay_order = @payment.js_pay(current_wechat_app)

      if @wxpay_order['code'].present? || @wxpay_order.blank?
        render 'wxpay_err', status: :unprocessable_entity
      else
        @payment.save
        render 'wxpay'
      end
    end

    private
    def set_wallet_payment
      wallet_template = WalletTemplate.default_where(default_params).default.take
      if wallet_template && current_client
        @wallets = current_client.wallets.where(wallet_template_id: wallet_template.id)
      elsif wallet_template
        @wallets = current_user.wallets.where(wallet_template_id: wallet_template.id)
      else
        @wallets = Wallet.none
      end
      @payment = WalletPayment.where(wallet_id: @wallets.pluck(:id)).find(params[:id])
    end

    def set_payment
      @payment = Payment.find params[:id]
    end

    def set_new_payment
      @payment = Payment.new(payment_params)
    end

    def set_new_payment_with_order
      @payment = @order.payments.build(payment_params)
      @payment.user = current_user
    end

    def set_new_payment_with_payment_order
      @payment = @payment_order.build_payment(payment_params)
      @payment.user = current_user
    end

    def set_payment_order
      @payment_order = PaymentOrder.find params[:payment_order_id]
    end

    def set_order
      @order = Order.default_where(default_params).find params[:order_id]
    end

    def payment_params
      p = params.fetch(:payment, {}).permit(
        :type,
        :wallet_id,
        :total_amount,
        :proof,
        payment_orders_attributes: [:order_id, :payment_amount, :state]
      )
      p.merge! default_form_params
    end

  end
end
