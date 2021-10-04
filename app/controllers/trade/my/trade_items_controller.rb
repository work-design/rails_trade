module Trade
  class My::TradeItemsController < My::BaseController
    before_action :set_trade_item, only: [:show, :promote, :update, :toggle, :destroy]

    def create
      trade_item = current_cart.trade_items.find_or_initialize_by(good_id: params[:good_id], good_type: params[:good_type])
      trade_item.assign_attributes trade_item_params
      if trade_item.persisted?
        params[:number] ||= 1
        trade_item.number += params[:number].to_i
      end
      trade_item.compute_promote
      trade_item.sum_amount
      trade_item.save

      @trade_items = @cart.trade_items.page(params[:page])
      @checked_ids = @cart.trade_items.checked.pluck(:id)
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
      @trade_item = current_cart.trade_items.find(&->(i){ i.id.to_s == params[:id] })
    end

    def trade_item_params
      params.fetch(:trade_item, {}).permit(
        :number
      )
    end

  end
end
