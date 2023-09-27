module Trade
  class My::PaymentOrdersController < My::BaseController
    before_action :set_order, only: [:wxpay]
    before_action :set_new_payment_order, only: [:new, :create]

    def index
      @payments = current_user.payments.page(params[:page])
    end

    def new
      @payment.total_amount = @payment_order.check_amount
    end

    def create
      @payment_order.state = 'pending'
      @payment.save
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

    def set_new_payment_order
      @payment_order = PaymentOrder.find params[:payment_order_id]
      @payment = @payment_order.build_payment(payment_params)
      @payment.user = current_user
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
