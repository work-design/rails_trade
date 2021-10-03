module Trade
  class My::PromoteCartsController < My::BaseController

    def index
      q_params = {}
      q_params.merge! params.permit(:state)

      @promote_carts = current_cart.promote_carts.default_where(q_params).page(params[:page])
    end

  end
end
