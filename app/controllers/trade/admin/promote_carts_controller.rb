module Trade
  class Admin::PromoteCartsController < Admin::BaseController
    before_action :set_promote_cart, only: [:show, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:promote_id, :user_id, :member_id, :promote_good_id)

      @promote_carts = PromoteCart.includes(:promote, cart: [:user, :member]).default_where(q_params).page(params[:page])
      if params[:promote_good_id]
        @promote_good = PromoteGood.find params[:promote_good_id]
      end
    end

    def new
      @promote_cart = PromoteCart.new(**params.permit(:promote_id, :promote_good_id, :cart_id))

      if params[:promote_id]
        @promote_goods = PromoteGood.where(promote_id: params[:promote_id]) # fixme
      else
        @promote_goods = PromoteGood.all
      end
    end


  end
end
