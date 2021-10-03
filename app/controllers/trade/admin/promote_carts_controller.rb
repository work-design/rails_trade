module Trade
  class Admin::PromoteCartsController < Admin::BaseController
    before_action :set_promote_cart, only: [:show, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:promote_id, :user_id, :member_id)

      @promote_carts = PromoteCart.includes(:buyer, :promote).default_where(q_params).page(params[:page])
      if params[:promote_good_id]
        @promote_good = PromoteGood.find params[:promote_good_id]
      end
    end

    def new
      @promote_cart = PromoteCart.new(**params.permit(:promote_id, :promote_good_id))
    end

    def search
      @carts = Cart.default_where('user.name-like': params['name-like'])
    end

    private
    def set_promote_cart
      @promote_cart = PromoteCart.find(params[:id])
    end

    def promote_cart_params
      params.fetch(:promote_cart, {}).permit(
        :cart_id,
        :promote_good_id,
        :status,
        :effect_at,
        :expire_at
      )
    end

  end
end
