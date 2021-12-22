module Trade
  class My::WalletLogsController < My::BaseController

    def index
      @wallet_logs = current_wallet.wallet_logs.order(id: :desc).page(params[:page]).per(params[:per])
    end

  end
end
