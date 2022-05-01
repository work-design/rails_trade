module Trade
  class My::PromoteGoodsController < My::BaseController

    def index
      q_params = {}
      q_params.merge! params.permit(:state)

      @promote_goods = current_cart.promote_goods.includes(:promote).default_where(q_params).page(params[:page])
    end

  end
end
