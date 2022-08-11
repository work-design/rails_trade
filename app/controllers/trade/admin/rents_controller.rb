module Trade
  class Admin::RentsController < Admin::BaseController
    before_action :set_item

    def index
      @rents = @item.rents.page(params[:page])
    end

    private
    def set_item
      @item = Item.find params[:item_id]
    end

  end
end
