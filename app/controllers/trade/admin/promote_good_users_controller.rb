module Trade
  class Admin::PromoteGoodUsersController < Admin::BaseController
    before_action :set_cart
    before_action :set_promotes, only: [:index]
    before_action :set_promote_good, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:good_type, :good_id)

      @promote_goods = @cart.promote_goods.where.not(user_id: nil).default_where(q_params).page(params[:page])
    end

    def goods
      @goods = params[:good_type].constantize.default_where(default_params).order(id: :desc)
      @promote_good = PromoteGood.new
    end

    def new
      @promote_good = @promote.promote_goods.build(type: 'Trade::PromoteGoodUser', good_type: params[:good_type])
    end

    def create
      @promote_good = @promote.promote_goods.build(type: 'Trade::PromoteGoodUser')
      @promote_good.assign_attributes promote_good_params

      if @promote_good.save
        render :create, locals: { model: @promote_good }
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

    def set_promotes
      @promotes = PromoteGoodType.verified.default_where(default_params)
    end

    def set_new_promote_good_user
      @promote_good_user = @cart.promote_good_users.build(promote_good_params)
    end

    def set_promote_good
      @promote_good = PromoteGood.find(params[:id])
    end

    def promote_good_params
      params.fetch(:promote_good, {}).permit(
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
