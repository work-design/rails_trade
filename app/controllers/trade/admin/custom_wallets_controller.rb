module Trade
  class Admin::CustomWalletsController < Admin::BaseController
    before_action :set_wallet_template
    before_action :set_custom_wallet, only: [:show, :edit, :update, :destroy, :actions]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit('name-like')

      @custom_wallets = @wallet_template.wallets.default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_wallet_template
      @wallet_template = WalletTemplate.find_by id: params[:wallet_template_id]
    end

    def set_custom_wallet
      @custom_wallet = @wallet_template.wallets.find(params[:id])
    end

    def wallet_params
      params.fetch(:wallet, {}).permit(
        :note
      )
    end

  end
end
