module Trade
  class Agent::CartsController < My::CartsController

    private
    def set_cart
      @cart = current_member.agent_carts.find(params[:id])
    end

  end
end

