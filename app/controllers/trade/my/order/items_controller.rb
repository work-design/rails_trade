module Trade
  class My::ItemsController < My::ItemsController
    before_action :set_order
    before_action :set_item, only: [:show, :edit, :update, :actions]

    private
    def set_order
      @order = current_user.orders.find params[:order_id]
    end

    def set_item
      @item = @order.items.find params[:id]
    end

    def item_params
      params.fetch(:item, {}).permit(
        :number,
        :note,
        :desk_id
      )
    end

  end
end
