module Trade
  class Admin::WalletPaymentsController < Admin::BaseController
    before_action :set_wallet
    before_action :set_wallet_payment, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_wallet_payment, only: [:new, :create]

    def index
      q_params = {}

      @wallet_payments = @wallet.wallet_payments.default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_wallet
      @wallet = Wallet.find params[:wallet_id]
    end

    def set_new_wallet_payment
      @wallet_payment = @wallet.wallet_payments.build(wallet_payment_params)
      @wallet_payment.notified_at ||= Time.current
    end

    def set_wallet_payment
      @wallet_payment = WalletPayment.find(params[:id])
    end

    def wallet_payment_params
      p = params.fetch(:wallet_payment, {}).permit(
        :total_amount,
        :notified_at,
        :comment
      )
      p.merge! operator_id: current_member.id
    end

  end
end
