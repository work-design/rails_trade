module Trade
  class My::WalletTemplatesController < My::BaseController
    before_action :set_wallet_template, only: [:show]

    def index
      @wallets = current_user.custom_wallets.where(member_id: nil)

      @wallet_templates = WalletTemplate.default_where(default_params).where.not(id: @wallets.pluck(:wallet_template_id).compact)
    end

    def token
      prepayment = WalletPrepayment.find_by token: params[:token]
      @wallet = current_user.wallets.find_or_initialize_by(wallet_template_id: prepayment.wallet_template_id)
    end

    def show
      @wallet = current_user.wallets.find_or_initialize_by(wallet_template_id: @wallet_template.id)
    end

    private
    def set_wallet_template
      @wallet_template = WalletTemplate.default_where(default_params).find(params[:id])
    end

  end
end
