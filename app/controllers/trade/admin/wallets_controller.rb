module Trade
  class Admin::WalletsController < Admin::BaseController
    before_action :set_wallet_template
    before_action :set_wallet, only: [:show, :edit, :update, :destroy]

    def index
      @wallets = @wallet_template.wallets.order(id: :desc).page(params[:page])
    end

    private
    def set_wallet_template
      @wallet_template = WalletTemplate.find params[:wallet_template_id]
    end

    def set_wallet
      @wallet = @wallet_template.wallets.find(params[:id])
    end

    def wallet_params
      params.fetch(:wallet, {}).permit(
        :account_bank,
        :account_name,
        :account_num
      )
    end

  end
end
