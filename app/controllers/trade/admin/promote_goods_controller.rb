module Trade
  class Admin::PromoteGoodsController < Admin::BaseController
    before_action :set_promote
    before_action :set_promote_good, only: [:show, :edit, :blacklist, :blacklist_new, :blacklist_create, :blacklist_search, :update, :destroy]
    before_action :set_new_promote_good, only: [:new, :create, :part_new, :part_create]

    def index
      @promote_goods = @promote.promote_goods.where(good_id: nil).order(good_type: :asc).available
    end

    def part
      @promote_goods = @promote.promote_goods.where(good_type: params[:good_type]).available
    end

    def blacklist
      @blacklists = @promote_good.blacklists.page(params[:page])
    end

    def blacklist_new
      @blacklist = @promote_good.blacklists.build
    end

    def blacklist_create
      @blacklist = @promote_good.blacklists.build(status: 'unavailable')
      @blacklist.assign_attributes blacklist_params

      if @blacklist.save
        render :blacklist_create, locals: { model: @blacklist }
      else
        render :blacklist_new, status: :unprocessable_entity
      end
    end

    def search
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit('name-like')

      @goods = params[:good_type].constantize.default_where(q_params)
    end

    private
    def set_promote
      @promote = Promote.find params[:promote_id]
    end

    def set_promote_good
      @promote_good = @promote.promote_goods.find params[:id]
    end

    def set_new_promote_good
      @promote_good = @promote.promote_goods.build promote_good_params
    end

    def blacklist_params
      params.fetch(:promote_good, {}).permit(
        :effect_at,
        :expire_at,
        :good_id
      )
    end

    def promote_good_params
      _p = params.fetch(:promote_good, {}).permit(
        :effect_at,
        :expire_at,
        :good_type,
        :good_id,
        :aim
      )
      _p.with_defaults! params.permit(:good_type)
    end

  end
end
