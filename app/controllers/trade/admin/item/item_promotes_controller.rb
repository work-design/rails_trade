module Trade
  class Admin::Item::ItemPromotesController < Admin::ItemPromotesController
    before_action :set_promote_good
    before_action :set_item_promote, only: [:show, :edit, :update, :destroy, :actions]

    def index
      q_params = {}
      q_params.merge! params.permit(:item_id, :promote_good_id, :cart_id)

      @item_promotes = @item.item_promotes.includes(:promote, :promote_good).default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_item
      @item = Item.find params[:item_id]
    end

  end
end
