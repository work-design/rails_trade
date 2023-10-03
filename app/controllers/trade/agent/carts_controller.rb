module Trade
  class Agent::CartsController < My::CartsController
    before_action :set_client, only: [:show]

    private
    def set_cart
      @cart = current_member.agent_carts.find(params[:id])
    end

    def set_client
      @cart.client || @cart.build_client
    end

    def cart_params
      params.fetch(:cart, {}).permit(
        :address_id,
        :auto,
        client_attributes: [:id, :identity, :nick_name, :extra]
      )
    end

  end
end

