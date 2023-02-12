module Trade
  class In::PaymentsController < My::PaymentsController

    private
    def set_order
      @order = current_organ.member_orders.find params[:order_id]
    end
  end
end

