module Trade
  class Admin::WalletAdvancesController < Admin::BaseController
    before_action :set_wallet
    before_action :set_wallet_advance, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:advance_id)

      @wallet_advances = @wallet.wallet_advances.default_where(q_params).order(id: :desc).page(params[:page])
    end

    def new
      @wallet_advance = @wallet.wallet_advances.build
    end

    def create
      @wallet_advance = @wallet.wallet_advances.build(wallet_advance_params)

      unless @wallet_advance.save
        render :new, locals: { model: @wallet_advance }, status: :unprocessable_entity
      end
    end

    private
    def set_wallet
      @wallet = Wallet.find params[:wallet_id]
    end

    def set_wallet_advance
      @wallet_advance = @wallet.wallet_advances.find(params[:id])
    end

    def wallet_advance_params
      params.fetch(:wallet_advance, {}).permit(
        :amount,
        :note
      )
    end

  end
end
