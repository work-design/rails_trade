module Trade
  class Our::ItemsController < My::ItemsController

    def promote
      render layout: false
    end

    private
    def set_cart
      @cart = Trade::Cart.get_cart(params, **default_form_params, **client_params)
    end

    def set_new_item
      @item = @cart.init_cart_item(params, operator_id: current_client.id, **client_params)
    end

    def set_item
      @item = current_client.organ.organ_items.find(params[:id])
    end

    def item_params
      params.fetch(:item, {}).permit(
        :number,
        :current_cart_id
      )
    end

  end
end
