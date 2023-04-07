module Trade
  class Admin::LawfulWalletsController < Admin::BaseController
    before_action :set_lawful_wallet, only: [:show, :edit, :update, :destroy, :actions]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit('name-like')

      @lawful_wallets = LawfulWallet.includes(:member, :user).default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_lawful_wallet
      @lawful_wallet = LawfulWallet.default_where(default_params).find(params[:id])
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
