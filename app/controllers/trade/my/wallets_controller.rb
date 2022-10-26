module Trade
  class My::WalletsController < My::BaseController
    before_action :set_wallet, only: [:show]
    before_action :set_new_order, only: [:show]

    def index
      @wallets = current_user.wallets.where(member_id: nil)
    end

    def token
      prepayment = WalletPrepayment.find_by token: params[:token]
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
