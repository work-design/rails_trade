module Trade
  class My::WalletsController < My::BaseController
    before_action :set_wallet, only: [:show]
    before_action :set_new_order, only: [:show]



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
