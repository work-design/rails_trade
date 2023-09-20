module Trade
  class Mem::ItemsController < My::ItemsController
    include Controller::Mem

    def index
      @items = current_client.items.page(params[:page])
    end

    private
    def set_new_item
      options = {}
      options.merge! client_params
      options.merge! params.permit(:good_id, :member_id, :number, :produce_on, :scene_id)
      options.compact_blank!

      @item = @cart.find_item(**options) || @cart.items.build(options)
      @item.status = 'checked'
      @item.assign_attributes params.permit(:station_id, :desk_id, :current_cart_id)
      @item.number = @item.number.to_i + (params[:number].presence || 1).to_i if @item.persisted?
    end

    def set_cart
      if params[:current_cart_id]
        @cart = Cart.find params[:current_cart_id]
      elsif item_params[:current_cart_id].present?
        @cart = Cart.find item_params[:current_cart_id]
      else
        options = {}
        options.merge! default_form_params
        options.merge! member_id: current_client.id
        @cart = Trade::Cart.where(options).find_or_create_by(good_type: params[:good_type], aim: params[:aim].presence || 'use')
      end
    end

    def set_item
      @item = current_client.items.find(params[:id])
    end

  end
end
