module Trade
  class My::WalletTemplatesController < My::BaseController
    before_action :set_cart, only: [:show, :code]
    before_action :set_wallet_template, only: [:show, :actions]
    before_action :set_new_order, only: [:show, :code]

    def index
      @wallets = current_user.custom_wallets.where(member_id: nil)

      @wallet_templates = WalletTemplate.default_where(default_params).where.not(id: @wallets.pluck(:wallet_template_id).compact)
    end

    def token_detect
      @wallet_prepayment = WalletPrepayment.unused.find_by token: params[:token]
      unless @wallet_prepayment
        render 'token_missing'
      end
    end

    def token_create
      prepayment = WalletPrepayment.unused.find_by token: params[:token]
      if prepayment
        @wallet = prepayment.execute(user_id: current_user.id)
      else
        render 'token_missing', locals: { message: '卡券已绑定或失效' }
      end
    end

    def code
      @wallet_template = WalletTemplate.default_where(default_params).find_by(code: params[:code])
      set_show_var
      render :show
    end

    def show
      set_show_var
    end

    private
    def set_wallet_template
      @wallet_template = WalletTemplate.default_where(default_params).find(params[:id])
    end

    def set_show_var
      @wallet = @cart.wallets.find_by(wallet_template_id: @wallet_template.id)
      @cards = @cart.cards.formal.pluck(:card_template_id)

      if @wallet
        @advances = @wallet_template.unopened_advances.without_card
        @card_advances = @wallet_template.unopened_advances.with_card
      else
        @advances = @wallet_template.opened_advances.without_card
        @card_advances = @wallet_template.opened_advances.with_card
      end
    end

    def set_new_order
      @order = current_user.orders.build
      @order.items.build
    end

  end
end
