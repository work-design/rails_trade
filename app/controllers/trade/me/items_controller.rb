module Trade
  class Me::ItemsController < My::ItemsController

    def index
      @items = current_member.items.order(id: :desc).page(params[:page])
    end

    private
    def set_item
      @item = current_member.items.find params[:id]
    end

  end
end

