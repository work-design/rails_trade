module Trade
  class Mem::ItemsController < My::ItemsController
    include Controller::Mem

    private
    def set_new_item
      options = {}
      options.merge! client_params
      options.merge! params.permit(:good_id, :member_id, :number, :produce_on, :scene_id, :fetch_oneself)
      options.compact_blank!

      @item = @cart.find_item(**options) || @cart.checked_items.build(options)
    end

    def set_cart
      if params[:current_cart_id]
        @cart = Cart.find params[:current_cart_id]
      else
        options = {}
        options.merge! default_form_params
        options.merge! client_params
        @cart = Trade::Cart.where(options).find_or_create_by(good_type: params[:good_type], aim: params[:aim].presence || 'use')
      end
    end

    def set_item
      @item = current_client.items.find(params[:id])
    end

  end
end
