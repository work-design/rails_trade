module Trade
  class Admin::WalletAdvancesController < Admin::BaseController
    before_action :set_wallet
    before_action :set_wallet_advance, only: [:show, :edit, :update, :destroy]
    before_action :set_new_wallet_advance, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! params.permit(:advance_id)

      @wallet_advances = @wallet.wallet_advances.default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_wallet
      @wallet = Wallet.find params[:wallet_id]
    end

    def set_wallet_advance
      @wallet_advance = @wallet.wallet_advances.find(params[:id])
    end

    def set_new_wallet_advance
      @wallet_advance = @wallet.wallet_advances.build(wallet_advance_params)
    end

    def wallet_advance_params
      p = params.fetch(:wallet_advance, {}).permit(
        :amount,
        :note
      )
      p.merge! operator_id: current_member.id
    end

    def _prefixes
      super do |pres|
        if params[:maintain_id]
          pres + ['crm/admin/base']
        else
          pres
        end
      end
    end

  end
end
