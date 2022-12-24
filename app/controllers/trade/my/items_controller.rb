module Trade
  class My::ItemsController < My::BaseController
    before_action :set_item, only: [:show, :update, :destroy, :actions, :promote, :toggle, :finish]
    before_action :set_new_item, only: [:create, :trial]


    def create
      @item.save
    end

    def trial
      @item.aim = 'use'
      @item.status = 'trial'
      @item.save
    end

    def promote
      render layout: false
    end

    def toggle
      if @item.status_init?
        @item.status = 'checked'
      elsif @item.status_checked?
        @item.status = 'init'
      end

      @item.save
    end

    def finish
      @item.rent_finish_at = Time.current
      @item.save
    end

    private
    def set_item
      @item = current_user.items.find params[:id]
    end

    def set_new_item
      options = {}
      options.merge! client_params
      options.merge! params.permit(:good_type, :good_id, :aim, :number, :produce_on, :scene_id, :station_id, :desk_id, :current_cart_id)

      @item = Item.new(options)
    end

    def item_params
      params.fetch(:item, {}).permit(
        :number,
        :desk_id,
        :current_cart_id
      )
    end

  end
end
