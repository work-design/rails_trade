module Trade
  class Our::ItemsController < My::ItemsController

    def promote
      render layout: false
    end

    private
    def set_new_item
      @item = @cart.init_cart_item(params, operator_id: current_client.id, **client_params)
    end

    def set_cart
      if params[:current_cart_id]
        @cart = Cart.find params[:current_cart_id]
      elsif item_params[:current_cart_id]
        @cart = Cart.find item_params[:current_cart_id]
      else
        options = {}
        options.merge! default_form_params
        options.merge! client_params
        @cart = Trade::Cart.where(options).find_or_create_by(good_type: params[:good_type], aim: params[:aim].presence || 'use')
      end
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
