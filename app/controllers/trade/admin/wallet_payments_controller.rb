module Trade
  class Admin::WalletPaymentsController < Admin::BaseController
    before_action :set_wallet
    before_action :set_wallet_payment, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}

      @wallet_payments = @wallet.wallet_payments.default_where(q_params).page(params[:page])
    end

    def new
      @wallet_payment = WalletPayment.new
    end

    def create
      @wallet_payment = WalletPayment.new(wallet_payment_params)

      unless @wallet_payment.save
        render :new, locals: { model: @wallet_payment }, status: :unprocessable_entity
      end
    end

    private
    def set_wallet
      @wallet = Wallet.find params[:wallet_id]
    end

    def set_wallet_payment
      @wallet_payment = WalletPayment.find(params[:id])
    end

    def wallet_payment_params
      params.fetch(:wallet_payment, {}).permit(
        :comment
      )
    end

  end
end
