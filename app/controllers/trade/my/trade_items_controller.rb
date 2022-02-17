module Trade
  class My::TradeItemsController < My::BaseController
    before_action :set_cart
    before_action :set_trade_item, only: [:show, :promote, :update, :toggle, :destroy]
    before_action :set_new_trade_item, only: [:create]

    def create
      @trade_item.save

      @trade_items = current_cart.trade_items.page(params[:page])
      @checked_ids = current_cart.trade_items.checked.pluck(:id)
    end

    def promote
      render layout: false
    end

    def toggle
      if @trade_item.init?
        @trade_item.status = 'checked'
      elsif @trade_item.checked?
        @trade_item.status = 'init'
      end

      @trade_item.save
    end

    private
    def set_trade_item
      @trade_item = @cart.trade_items.find(&->(i){ i.id.to_s == params[:id] })
    end

    def set_cart
      options = {
        user_id: current_user.id,
        member_id: nil
      }
      options.merge! default_params

      @cart = Cart.find_or_create_by(options)
    end

    def set_new_trade_item
      @trade_item = @cart.get_trade_item(params[:good_type], params[:good_id], params[:number], params[:produce_plan_id].presence)
    end

    def trade_item_params
      params.fetch(:trade_item, {}).permit(
        :number
      )
    end

  end
end
