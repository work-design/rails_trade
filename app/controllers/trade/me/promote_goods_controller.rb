module Trade
  class Me::PromoteGoodsController < My::PromoteGoodsController
    include Controller::Me

    def index
      q_params = {}
      q_params.merge! params.permit(:state)

      @promote_goods = current_cart.promote_goods.default_where(q_params).page(params[:page])
    end



  end
end
