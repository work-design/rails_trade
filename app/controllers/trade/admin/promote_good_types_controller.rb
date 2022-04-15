module Trade
  class Admin::PromoteGoodTypesController < Admin::BaseController
    before_action :set_promote
    before_action :set_new_promote_good, only: [:new, :create]
    before_action :set_promote_good, only: [:show, :edit, :blacklist, :blacklist_new, :blacklist_create, :blacklist_search, :update, :destroy]

    def index
      @promote_goods = @promote.promote_good_types.where(good_id: nil).available
    end

    def new
    end

    def create
      @promote_good.save
    end

    def show
    end

    def edit
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

    def blacklist_search
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit('name-like')

      @goods = @promote_good.good_type.constantize.default_where(q_params)
    end

    def destroy
      @promote_good.destroy
    end

    private
    def set_promote
      @promote = Promote.find params[:promote_id]
    end

    def set_promote_good
      @promote_good = @promote.promote_goods.find params[:id]
    end

    def set_new_promote_good
      @promote_good = @promote.promote_goods.build(type: 'Trade::PromoteGoodType')
      @promote_good.assign_attributes promote_good_params
    end

    def blacklist_params
      params.fetch(:promote_good, {}).permit(
        :effect_at,
        :expire_at,
        :good_id
      )
    end

    def promote_good_params
      params.fetch(:promote_good, {}).permit(
        :effect_at,
        :expire_at,
        :good_type,
        :good_id
      )
    end

  end
end
