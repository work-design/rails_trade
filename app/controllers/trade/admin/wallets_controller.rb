module Trade
  class Admin::WalletsController < Admin::BaseController
    before_action :set_wallet, only: [:show, :edit, :update, :destroy, :actions]

    def index
      q_params = {}
      q_params.merge! 'id-desc': 1 unless params.key? 'amount-desc'
      q_params.merge! default_params
      q_params.merge! params.permit('name-like')

      @wallets = CustomWallet.default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_wallet
      @wallet = Wallet.find(params[:id])
    end

    def wallet_params
      params.fetch(:wallet, {}).permit(
        :note
      )
    end

  end
end
