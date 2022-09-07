module Trade
  class My::LawfulWalletsController < My::BaseController
    before_action :set_wallet, only: [:show]
    before_action :set_new_order, only: [:show]

    def show
    end

    private
    def set_wallet
      @wallet = current_user.lawful_wallet
    end

    def set_new_order
      @order = current_user.orders.build
      @order.items.build
    end

  end
end
