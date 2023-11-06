module Trade
  class In::WalletTemplatesController < Admin::WalletTemplatesController
    before_action :set_wallet_template, only: [:show]

    def show
      @wallet = current_client.wallets.find_or_initialize_by(wallet_template_id: @wallet_template.id)
    end

    private
    def set_wallet_template
      @wallet_template = WalletTemplate.default_where(default_params).find(params[:id])
    end
  end
end
