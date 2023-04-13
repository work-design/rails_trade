module Trade
  class Mem::PromoteGoodsController < My::PromoteGoodsController
    include Controller::Mem

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:state)

      @promote_goods = current_client.promote_goods.default_where(q_params).page(params[:page])
    end

  end
end
