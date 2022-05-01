module Trade
  class Admin::ItemPromotesController < Admin::BaseController
    before_action :set_item_promote, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:trade_item_id, :cart_id)

      @item_promotes = ItemPromote.includes(:promote).default_where(q_params).page(params[:page])
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
