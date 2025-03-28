module Trade
  class My::LawfulWalletsController < My::BaseController
    before_action :set_lawful_wallet, only: [:show, :edit, :update, :account]
    before_action :set_new_order, only: [:show]
    before_action :set_cart, only: [:show]

    def account
    end

    private
    def set_new_order
      @order = current_user.orders.build
      @order.items.build
    end

    def lawful_wallet_params
      params.fetch(:lawful_wallet, {}).permit(
        wallet_frozens_attributes: {}
      )
    end

  end
end
