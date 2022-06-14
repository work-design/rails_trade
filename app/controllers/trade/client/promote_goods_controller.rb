module Trade
  class Client::PromoteGoodsController < My::PromoteGoodsController

    def index
      q_params = {}
      q_params.merge! params.permit(:state)

      @promote_goods = current_cart.promote_goods.default_where(q_params).page(params[:page])
    end

  end
end
