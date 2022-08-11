module Trade
  class Panel::ItemsController < Panel::BaseController
    before_action :set_item, only: [:show, :carts, :edit, :update, :destroy]

    def index
      @items = Item.includes(:carts, :organ_carts).order(id: :desc).page(params[:page])
    end

    def carts
    end

    private
    def set_item
      @item = Item.find params[:id]
    end

  end
end
