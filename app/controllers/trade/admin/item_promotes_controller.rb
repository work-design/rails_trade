module Trade
  class Admin::ItemPromotesController < Admin::BaseController
    before_action :set_promote_good
    before_action :set_item_promote, only: [:show, :edit, :update, :destroy, :actions]

    def index
      q_params = {}
      q_params.merge! params.permit(:item_id, :promote_good_id, :cart_id)

      @item_promotes = @promote_good.item_promotes.includes(:promote, :item).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def new
      @item_promote = ItemPromote.new
    end

    def create
      @item_promote = ItemPromote.new(item_promote_params)

      unless @item_promote.save
        render :new, locals: { model: @item_promote }, status: :unprocessable_entity
      end
    end

    private
    def set_promote_good
      @promote_good = PromoteGood.find params[:promote_good_id]
    end

    def set_item_promote
      @item_promote = ItemPromote.find(params[:id])
    end

    def item_promote_params
      p = params.fetch(:item_promote, {}).permit(
        :amount,
        :note
      )
      p.merge! edited: true
    end

  end
end
