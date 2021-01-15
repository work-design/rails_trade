module Trade
  class Admin::PromoteGoodsController < Admin::BaseController
    before_action :set_promote_good, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:promote_id, :good_type, :good_id)

      @promote_goods = PromoteGood.default_where(q_params).page(params[:page])
      if params[:promote_id]
        @promote = Promote.find params[:promote_id]
      end
    end

    def goods
      # todo support search
      @goods = params[:good_type].constantize.default_where(default_params).order(id: :desc)
      @promote_good = PromoteGood.new
    end

    def show
    end

    def new
      @promote_good = PromoteGood.new(params.permit(:promote_id, :good_type, :good_id))
    end

    def edit
    end

    def create
      @promote_good = PromoteGood.new(promote_good_params)

      unless @promote_good.save
        render :new, locals: { model: @promote_good }, status: :unprocessable_entity
      end
    end

    def update
      @promote_good.assign_attributes(promote_good_params)

      unless @promote_good.save
        render :edit, locals: { model: @promote_good }, status: :unprocessable_entity
      end
    end

    def destroy
      @promote_good.destroy
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
        :effect_at,
        :expire_at,
        :status
      )
    end

  end
end
