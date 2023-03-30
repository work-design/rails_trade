module Trade
  class Our::LawfulWalletsController < My::LawfulWalletsController
    before_action :set_lawful_wallet, only: [:show, :account, :edit, :update]

    def show
      q_params = { lawful: true }
      q_params.merge! default_params

      @advances = Advance.default_where(q_params)
    end

    private
    def set_new_order
      @order = current_client.orders.build
      @order.items.build
    end

  end
end