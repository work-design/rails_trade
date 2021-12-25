module Trade
  class Admin::WalletPrepaymentsController < Admin::BaseController
    before_action :set_wallet_template
    before_action :set_wallet_prepayment, only: [:show, :edit, :update, :destroy]

    def index
      @wallet_prepayments = @wallet_template.wallet_prepayments.page(params[:page])
    end

    def new
      @wallet_prepayment = @wallet_template.wallet_prepayments.build
    end

    def create
      @wallet_prepayment = @wallet_template.wallet_prepayments.build(wallet_prepayment_params)

      unless @wallet_prepayment.save
        render :new, locals: { model: @wallet_prepayment }, status: :unprocessable_entity
      end
    end

    private
    def set_wallet_template
      @wallet_template = WalletTemplate.find params[:wallet_template_id]
    end

    def set_wallet_prepayment
      @wallet_prepayment = WalletPrepayment.find(params[:id])
    end

    def wallet_prepayment_params
      params.fetch(:wallet_prepayment, {}).permit(
        :amount,
        :token,
        :expire_at
      )
    end

  end
end
