module Trade
  class Me::PromoteCartsController < My::PromoteCartsController

    def index
      q_params = {}
      q_params.merge! params.permit(:state)

      @promote_carts = current_cart.promote_carts.default_where(q_params).page(params[:page])
    end

    def self.local_prefixes
      [controller_path, 'trade/me/base', 'me']
    end

  end
end
