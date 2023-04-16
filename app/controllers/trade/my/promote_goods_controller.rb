module Trade
  class My::PromoteGoodsController < My::BaseController
    before_action :set_global_promotes, only: [:index]
    before_action :set_cart, only: [:index]

    def index
      q_params = {
        over_limit: false
      }
      q_params.merge! params.permit(:state)

      @promote_goods = @cart.promote_goods.includes(:promote).default_where(q_params).page(params[:page])
    end

    private
    def set_global_promotes
      @global_promote_goods = PromoteGood.effective.where(user_id: nil)
    end

  end
end
