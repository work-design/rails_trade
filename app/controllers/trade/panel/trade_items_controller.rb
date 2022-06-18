module Trade
  class Panel::TradeItemsController < Panel::BaseController
    before_action :set_trade_item, only: [:show, :carts, :edit, :update, :destroy]

    def index
      @trade_items = TradeItem.includes(:carts, :organ_carts).order(id: :desc).page(params[:page])
    end

    def carts
    end

    private
    def set_trade_item
      @trade_item = TradeItem.find params[:id]
    end

  end
end
