module Trade
  class Our::WalletLogsController < My::WalletLogsController
    before_action :set_wallet

    private
    def set_wallet
      @wallet = current_client.wallets.find params[:wallet_id]
    end

  end
end
