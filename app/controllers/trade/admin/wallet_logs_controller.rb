module Trade
  class Admin::WalletLogsController < Admin::BaseController
    before_action :set_wallet
    before_action :set_wallet_log, only: [:show, :edit, :update, :destroy, :actions]

    def index
      q_params = {}

      @wallet_logs = @wallet.wallet_logs.includes(:wallet).default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_wallet
      @wallet = Wallet.find params[:wallet_id]
    end

    def set_wallet_log
      @wallet_log = WalletLog.find(params[:id])
    end

  end
end
