module Trade
  class Our::PaymentsController < My::PaymentsController

    private
    def set_delivery
      @delivery = current_client.deliveries.find params[:id]
    end

    def item_params
      params.fetch(:delivery, {}).permit(
        :number,
        :current_cart_id,
        :fetch_start_at,
        :fetch_finish_at
      )
    end

  end
end
