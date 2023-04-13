module Trade
  class Our::PromoteGoodsController < My::PromoteGoodsController
    include Controller::Our

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:state)

      @promote_goods = current_client.organ.promote_goods.default_where(q_params).page(params[:page])
    end

  end
end
