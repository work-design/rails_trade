module Trade
  class Me::TradeItemsController < My::TradeItemsController
    include Controller::Me
    before_action :set_trade_item, only: [:show, :promote, :update, :toggle, :destroy]
    before_action :set_new_trade_item, only: [:create]

    def create
      @trade_item.agent_id = params[:agent_id]
      @trade_item.save
    end

    def promote
      render layout: false
    end

    def toggle
      if @trade_item.status_init?
        @trade_item.status = 'checked'
      elsif @trade_item.status_checked?
        @trade_item.status = 'init'
      end

      @trade_item.save
    end

    private
    def set_new_trade_item
      options = {
        user_id: current_user.id,
        member_id: current_member.id
      }
      options.merge! params.permit(:good_type, :good_id, :number, :produce_on, :scene_id)

      @trade_item = TradeItem.get_trade_item(**options.to_h.symbolize_keys)
    end

    def set_trade_item
      @trade_item = current_member.trade_items.find(params[:id])
    end

    def trade_item_params
      params.fetch(:trade_item, {}).permit(
        :number
      )
    end

  end
end
