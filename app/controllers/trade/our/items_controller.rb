module Trade
  class Our::ItemsController < My::ItemsController
    before_action :set_item, only: [:show, :promote, :update, :toggle, :destroy]
    before_action :set_new_item, only: [:create]

    def promote
      render layout: false
    end

    private
    def set_new_item
      options = {}
      options.merge! client_params
      options.merge! params.permit(:good_type, :good_id, :member_id, :aim, :number, :produce_on, :scene_id, :fetch_oneself)

      @item = Item.new(**options.to_h.symbolize_keys)
    end

    def set_item
      @item = current_client.items.find(params[:id])
    end

    def item_params
      params.fetch(:item, {}).permit(
        :number
      )
    end

  end
end
