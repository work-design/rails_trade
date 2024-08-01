module Trade
  class Mem::ItemsController < My::ItemsController
    include Controller::Mem

    def index
      @items = current_client.items.page(params[:page])
    end

    private
    def set_cart
      @cart = Cart.get_cart(params, member_id: current_client.id, **default_form_params)
    end

    def set_new_item
      @item = @cart.init_cart_item(params, **client_params)
    end

    def set_item
      @item = current_client.items.find(params[:id])
    end

  end
end
