module Trade
  class My::PaymentsController < My::BaseController
    before_action :set_payment, only: [:show, :edit, :update, :destroy]

    def index
      @payments = current_user.payments.page(params[:page])
    end

    def create
      @payment = Payment.new(payment_params)

      if params[:xx] == 'x' && @payment.save
        render 'create'
      else
        render :new, locals: { model: @payment }, status: :unprocessable_entity
      end
    end

    private
    def set_payment
      if current_wallet
        @payment = current_wallet.wallet_payments.find(params[:id])
      end
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
