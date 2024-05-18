module Trade
  class Admin::Cart::PromoteGoodsController < Admin::PromoteGoodsController
    before_action :set_cart
    before_action :set_promote_good, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_promote_good, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! params.permit(:good_type, :good_id)

      @promote_goods = @cart.promote_goods.default_where(q_params)
      promote_ids = @cart.promote_goods.pluck(:promote_id) + @promote_good_users.pluck(:promote_id)
      @promotes = Promote.where.not(id: promote_ids).default_where(default_params)
    end

    def goods
      @goods = params[:good_type].constantize.default_where(default_params).order(id: :desc)
      @promote_good = PromoteGood.new
    end

    def create
      @promote_good_user.expire_at ||= Time.current.since(1.year)

      if @promote_good_user.save
        render :create, locals: { model: @promote_good_user }
      else
        render :new, status: :unprocessable_entity
      end
    end

    def user
      @promote_good = PromoteGood.new(params.permit(:promote_id, :good_type, :good_id))
    end

    def user_search
      @accounts = Auth::Account.includes(:user, members: :organ).where(identity: params[:identity])
    end

    private
    def set_cart
      @cart = Cart.find params[:cart_id]
    end

    def set_new_promote_good
      @promote_good_user = @cart.promote_good_users.build(promote_good_user_params)
    end

    def set_promote_good
      @promote_good_user = @cart.promote_good_users.find(params[:id])
    end

    def promote_good_params
      _p = params.fetch(:promote_good, {}).permit(
        :promote_id,
        :good_id,
        :effect_at,
        :expire_at,
        :use_limit,
        :status
      )
      _p.merge! promote_id: params[:promote_id] if params[:promote_id]
      _p
    end

  end
end
