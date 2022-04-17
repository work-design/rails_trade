module Trade
  class Admin::PromoteGoodsController < Admin::BaseController
    before_action :set_promote_good, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:promote_id, :good_type, :good_id)

      @promote_goods = PromoteGood.default_where(q_params).page(params[:page])
    end

    def goods
      @goods = params[:good_type].constantize.default_where(default_params).order(id: :desc)
      @promote_good = PromoteGood.new
    end

    def new
      @promote_good = PromoteGood.new(params.permit(:promote_id, :good_type, :good_id))
    end

    def user
      @promote_good = PromoteGood.new(params.permit(:promote_id, :good_type, :good_id))
    end

    def search
      @accounts = Auth::Account.includes(:user, members: :organ).where(identity: params[:identity])
    end

    private
    def set_promote_good
      @promote_good = PromoteGood.find(params[:id])
    end

    def promote_good_params
      params.fetch(:promote_good, {}).permit(
        :promote_id,
        :good_type,
        :good_id,
        :member_id,
        :user_id,
        :effect_at,
        :expire_at,
        :status
      )
    end

  end
end
