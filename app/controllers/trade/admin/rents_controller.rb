module Trade
  class Admin::RentsController < Admin::BaseController
    before_action :set_trade_item

    def index
      @rents = @trade_item.rents.page(params[:page])
    end

    private
    def set_trade_item
      @trade_item = Item.find params[:trade_item_id]
    end

  end
end
