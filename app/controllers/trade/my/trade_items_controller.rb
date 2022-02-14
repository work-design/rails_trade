module Trade
  class My::TradeItemsController < My::BaseController
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
      @trade_item = current_cart.trade_items.find(&->(i){ i.id.to_s == params[:id] })
    end

    def set_new_trade_item
      options = {
        member_id: params[:member_id],
        user_id: params[:user_id],
        organ_id: params[:organ_id],
        good_type: params[:good_type],
        good_id: params[:good_id]
      }
      options.compact!
      options.merge! produce_plan_id: params[:produce_plan_id]

      @trade_item = TradeItem.find_or_initialize_by(options)
      if @trade_item.persisted? && @trade_item.checked?
        @trade_item.number += (params[:number].present? ? params[:number].to_i : 1)
      elsif @trade_item.persisted? && @trade_item.init?
        @trade_item.status = 'checked'
        @trade_item.number = 1
      else
        @trade_item.status = 'checked'
      end

      @trade_item
    end

    def trade_item_params
      params.fetch(:trade_item, {}).permit(
        :number
      )
    end

  end
end
