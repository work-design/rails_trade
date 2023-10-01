module Trade
  class Agent::ItemsController < Trade::My::ItemsController
    before_action :set_item, only: [:show, :toggle, :edit, :update, :destroy]
    before_action :set_new_item, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! params.permit(:good_id)

      @items = current_organ.member_ordered_items.includes(:organ).default_where(q_params).page(params[:page])
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
    def set_address
      @address = current_user.principal_addresses.find params[:principal_address_id]
    end

    def set_new_item
      options = { member_id: current_member.id }
      options.merge! params.permit(:good_type, :good_id, :member_id, :number, :produce_on, :scene_id)

      @item = Item.new(**options.to_h.symbolize_keys)
    end

    def set_item
      @item = Trade::Item.find(params[:id])
    end

    def item_params
      params.fetch(:item, {}).permit(
        :number
      )
    end

  end
end
