module Trade
  class In::PaymentsController < Admin::PaymentsController

    private
    def set_order
      @order = current_organ.organ_orders.find params[:order_id]
    end
  end
end

