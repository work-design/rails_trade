module Trade
  class Admin::HoldsController < Admin::BaseController
    before_action :set_item

    def index
      @holds = @item.holds.page(params[:page])
    end

    private
    def set_item
      @item = Item.find params[:item_id]
    end

    def hold_params
      params.fetch(:hold, {}).permit(
        :rent_start_at,
        :rent_finish_at
      )
    end

  end
end
