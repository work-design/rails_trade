module Trade
  class My::WalletsController < My::BaseController
    before_action :set_wallet, only: [:show]
    before_action :set_new_order, only: [:show]

    def show
      @advances = @wallet.wallet_template.unopened_advances.without_card
      @card_advances = @wallet.wallet_template.unopened_advances.with_card
    end

    private
    def set_wallet
      @wallet = current_user.wallets.find params[:id]
    end

    def set_new_order
      @order = current_user.orders.build
      @order.items.build
    end

  end
end
