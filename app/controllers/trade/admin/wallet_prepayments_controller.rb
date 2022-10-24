module Trade
  class Admin::WalletPrepaymentsController < Admin::BaseController
    before_action :set_wallet_template
    before_action :set_wallet_prepayment, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_wallet_prepayment, only: [:new, :create]

    def index
      @wallet_prepayments = @wallet_template.wallet_prepayments.page(params[:page])
    end

    private
    def set_wallet_template
      @wallet_template = WalletTemplate.find params[:wallet_template_id]
    end

    def set_wallet_prepayment
      @wallet_prepayment = WalletPrepayment.find(params[:id])
    end

    def set_new_wallet_prepayment
      @wallet_prepayment = @wallet_template.wallet_prepayments.build(wallet_prepayment_params)
    end

    def wallet_prepayment_params
      params.fetch(:wallet_prepayment, {}).permit(
        :amount,
        :expire_at
      )
    end

  end
end
