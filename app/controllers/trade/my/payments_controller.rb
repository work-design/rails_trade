module Trade
  class My::PaymentsController < My::BaseController
    before_action :set_order, only: [:order_new, :order_create]
    before_action :set_new_payment_with_order, only: [:order_new, :order_create]
    before_action :set_payment_order, only: [:payment_order_new, :payment_order_create]
    before_action :set_new_payment_with_payment_order, only: [:payment_order_new, :payment_order_create]
    before_action :set_payment, only: [:show, :edit, :update, :destroy]
    before_action :set_new_payment, only: [:new, :create]

    def index
      @payments = current_user.payments.page(params[:page])
    end

    def create
      if @payment.save
        render 'create'
      else
        render :new, locals: { model: @payment }, status: :unprocessable_entity
      end
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

    def wxpay_pay
      @payment = @order.payments.build type: 'Trade::WxpayPayment'
      @wxpay_order = @payment.wxpay_order(current_wechat_app)

      if @wxpay_order['code'].present? || @wxpay_order.blank?
        render 'wxpay_pay_err', status: :unprocessable_entity
      else
        render 'wxpay_pay'
      end
    end

    def edit
      @payment = Payment.find params[:id]
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
    end

    def set_new_payment_with_payment_order
      @payment = @payment_order.build_payment(payment_params)
    end

    def set_payment_order
      @payment_order = PaymentOrder.find params[:payment_order_id]
    end

    def set_order
      @order = Order.default_where(default_params).find params[:order_id]
    end

    def payment_params
      params.fetch(:payment, {}).permit(
        :type,
        :wallet_id,
        :total_amount,
        :proof,
        payment_orders_attributes: [:order_id, :check_amount, :state]
      )
    end

  end
end
