module Trade
  class My::LawfulWalletsController < My::BaseController
    before_action :set_lawful_wallet, only: [:show, :edit, :update, :account]
    before_action :set_new_order, only: [:show]

    def account
    end

    private
    def set_new_order
      @order = current_user.orders.build
      @order.items.build
    end

  end
end
