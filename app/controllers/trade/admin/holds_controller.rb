module Trade
  class Admin::HoldsController < Admin::BaseController
    before_action :set_item

    def index
      @holds = @item.holds.page(params[:page])
    end

    private
    def set_item
      @item = Item.find params[:item_id]
    end

  end
end
