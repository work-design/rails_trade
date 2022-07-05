module Trade
  class My::TradeItemsController < My::BaseController
    before_action :set_trade_item, only: [:show, :promote, :update, :toggle, :destroy]
    before_action :set_new_trade_item, only: [:create, :trial]

    def create
      @trade_item.save
    end

    def promote
      render layout: false
    end

    def trial
      @trade_item.status = 'trial'
      @trade_item.save
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
    def set_trade_item
      @trade_item = current_user.trade_items.find params[:id]
    end

    def set_new_trade_item
      options = {}
      options.merge! client_params
      options.merge! params.permit(:good_type, :good_id, :aim, :number, :produce_on, :scene_id, :fetch_oneself, :current_cart_id)

      @trade_item = TradeItem.new(options)
    end

    def trade_item_params
      params.fetch(:trade_item, {}).permit(
        :number,
        :current_cart_id,
        :fetch_start_at,
        :fetch_finish_at
      )
    end

  end
end
