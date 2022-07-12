module Trade
  class My::PaymentsController < My::BaseController
    before_action :set_payment, only: [:show, :edit, :update, :destroy]
    before_action :set_new_payment, only: [:new, :create, :order_new, :order_create]
    before_action :set_order, only: [:order_new, :order_create]

    def index
      @payments = current_user.payments.page(params[:page])
    end

    def create
      if params[:xx] == 'x' && @payment.save
        render 'create'
      else
        render :new, locals: { model: @payment }, status: :unprocessable_entity
      end
    end

    def order_new
      @payment.total_amount = @order.unreceived_amount
    end

    def order_create
      @payment = @order.payments.build(payment_params)

      payment_order = @order.payment_orders.find(&:new_record?)
      payment_order.check_amount = @payment.total_amount
      @payment.save
    end

    private
    def set_payment
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

    def set_new_payment
      @payment = Payment.new(payment_params)
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
        payment_orders_attributes: [:order_id, :check_amount, :state]
      )
      p.merge! default_form_params
    end

  end
end
