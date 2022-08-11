module Trade
  class My::ItemsController < My::BaseController
    before_action :set_item, only: [:show, :promote, :update, :toggle, :destroy]
    before_action :set_new_item, only: [:create, :trial]

    def create
      @item.save
    end

    def promote
      render layout: false
    end

    def trial
      @item.status = 'trial'
      @item.save
    end

    def toggle
      if @item.status_init?
        @item.status = 'checked'
      elsif @item.status_checked?
        @item.status = 'init'
      end

      @item.save
    end

    private
    def set_item
      @item = current_user.items.find params[:id]
    end

    def set_new_item
      options = {}
      options.merge! client_params
      options.merge! params.permit(:good_type, :good_id, :aim, :number, :produce_on, :scene_id, :fetch_oneself, :current_cart_id)

      @item = Item.new(options)
    end

    def item_params
      params.fetch(:item, {}).permit(
        :number,
        :current_cart_id,
        :fetch_start_at,
        :fetch_finish_at
      )
    end

  end
end
