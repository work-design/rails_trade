module Trade
  class Admin::WalletFrozensController < Admin::BaseController
    before_action :set_wallet
    before_action :set_wallet_frozen, only: [:show, :edit, :update, :destroy]
    before_action :set_new_wallet_frozen, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! params.permit(:frozen_id)

      @wallet_frozens = @wallet.wallet_frozens.default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_wallet
      @wallet = Wallet.find params[:wallet_id]
    end

    def set_wallet_frozen
      @wallet_frozen = @wallet.wallet_frozens.find(params[:id])
    end

    def set_new_wallet_frozen
      @wallet_frozen = @wallet.wallet_frozens.build(wallet_frozen_params)
    end

    def set_filter_columns
      @filter_columns = set_filter_i18n(
        'created_at' => { type: 'datetime', default: true }
      )
    end

    def wallet_frozen_params
      params.fetch(:wallet_frozen, {}).permit(
        :amount,
        :note
      )
    end

  end
end
