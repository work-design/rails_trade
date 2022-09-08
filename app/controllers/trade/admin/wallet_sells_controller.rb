module Trade
  class Admin::WalletSellsController < Admin::BaseController
    before_action :set_wallet
    before_action :set_wallet_sell, only: [:show, :edit, :update, :destroy, :actions]

    def index
      q_params = {}

      @wallet_sells = @wallet.wallet_sells.includes(:wallet, :item).default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_wallet
      @wallet = Wallet.find params[:wallet_id]
    end

    def set_wallet_sell
      @wallet_sell = @wallet.wallet_sells.find(params[:id])
    end
  end
end
