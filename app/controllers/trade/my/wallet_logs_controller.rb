module Trade
  class My::WalletLogsController < My::BaseController
    before_action :set_wallet

    def index
      @wallet_logs = @wallet.wallet_logs.order(id: :desc).page(params[:page]).per(params[:per])
    end

    private
    def set_wallet
      @wallet = current_user.wallets.find params[:wallet_id]
    end

  end
end
