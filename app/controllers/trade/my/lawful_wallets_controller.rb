module Trade
  class My::LawfulWalletsController < My::BaseController
    before_action :set_lawful_wallet, only: [:show, :account, :edit, :update]
    before_action :set_new_order, only: [:show]

    def show
      q_params = { lawful: true }
      q_params.merge! default_params

      @advances = Advance.default_where(q_params)
    end

    def account
    end

    private
    def set_new_order
      @order = current_user.orders.build
      @order.items.build
    end

  end
end
