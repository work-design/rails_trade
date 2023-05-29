module Trade
  class My::HoldsController < My::BaseController
    before_action :set_item
    before_action :set_hold, only: [:show]

    def index
      @holds = @item.holds
    end

    private
    def set_item
      @item = Item.find params[:item_id]
    end

    def set_hold
      @hold = @item.holds.find params[:id]
    end

  end
end
