module Trade
  class Admin::PromoteGoodUsersController < Admin::BaseController
    before_action :set_cart
    before_action :set_promote_good_types, only: [:index]
    before_action :set_promote_good_user, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_promote_good_user, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! params.permit(:good_type, :good_id)

      @promote_good_users = @cart.promote_good_users.default_where(q_params).page(params[:page])
    end

    def goods
      @goods = params[:good_type].constantize.default_where(default_params).order(id: :desc)
      @promote_good = PromoteGood.new
    end

    def new
    end

    def create
      @promote_good_user.expire_at = Time.current.since(1.year)
      if @promote_good_user.save
        render :create, locals: { model: @promote_good_user }
      else
        render :new, status: :unprocessable_entity
      end
    end

    def user
      @promote_good = PromoteGood.new(params.permit(:promote_id, :good_type, :good_id))
    end

    def good_search
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit('name-like')

      @goods = params[:good_type].constantize.default_where(q_params)
    end

    def user_search
      @accounts = Auth::Account.includes(:user, members: :organ).where(identity: params[:identity])
    end

    private
    def set_cart
      @cart = Cart.find params[:cart_id]
    end

    def set_promote_good_types
      ids = @cart.promote_good_types.pluck(:id)
      @promote_good_types = PromoteGoodType.verified.where.not(id: ids).default_where(default_params)
    end

    def set_new_promote_good_user
      @promote_good_user = @cart.promote_good_users.build(promote_good_user_params)
    end

    def set_promote_good_user
      @promote_good_user = @cart.promote_good_users.find(params[:id])
    end

    def promote_good_user_params
      params.fetch(:promote_good_user, {}).permit(
        :promote_id,
        :good_id,
        :effect_at,
        :expire_at,
        :use_limit,
        :status
      )
    end

  end
end
