module Trade
  class Our::ItemsController < My::ItemsController

    def promote
      render layout: false
    end

    private
    def set_new_item
      options = {
        operator_id: current_client.id
      }
      options.merge! client_params
      options.merge! params.permit(:good_id, :member_id, :number, :produce_on, :scene_id)
      options.compact_blank!

      @item = @cart.find_item(**options) || @cart.items.build(options)
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
      @item = current_client.organ.organ_items.find(params[:id])
    end

    def item_params
      params.fetch(:item, {}).permit(
        :number
      )
    end

  end
end
