module Trade
  class My::HoldsController < My::BaseController
    before_action :set_item
    before_action :set_packaged, only: [:show]

    def index
      @packageds = @item.packageds
    end

    private
    def set_item
      @item = Item.find params[:item_id]
    end

    def set_packaged
      @packaged = @item.packages.find params[:id]
    end

  end
end
