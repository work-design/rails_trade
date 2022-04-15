module Trade
  class Admin::PromoteGoodTypesController < Admin::BaseController
    before_action :set_promote
    before_action :set_new_promote_good, only: [:new, :create]

    def index
      @promote_goods = @promote.promote_goods.page(params[:page])
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
