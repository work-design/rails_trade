module Trade
  class Mem::WalletTemplatesController < My::WalletTemplatesController
    before_action :set_wallet_template, only: [:show, :actions]

    def index
      @wallets = current_client.custom_wallets.where(default_params)

      @wallet_templates = WalletTemplate.default_where(default_params).where.not(id: @wallets.pluck(:wallet_template_id).compact)
    end

    def token
      prepayment = WalletPrepayment.find_by token: params[:token]
      @wallet = prepayment.execute(user_id: current_user.id)

      redirect_to controller: 'wallets', action: 'show', id: @wallet.id
    end

    def show
      @wallet = current_client.wallets.where(default_params).find_or_initialize_by(wallet_template_id: @wallet_template.id)
    end

    private
    def set_wallet_template
      @wallet_template = WalletTemplate.default_where(default_params).find(params[:id])
    end

    def set_new_order
      @order = current_client.orders.build
      @order.items.build
    end

  end
end
