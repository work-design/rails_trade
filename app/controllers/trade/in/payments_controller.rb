module Trade
  class In::PaymentsController < Admin::PaymentsController

    def index
      @payments = Payment.joins(:orders).where(orders: { member_organ_id: current_organ.id }).order(id: :desc).page(params[:page])
    end

    private
    def set_order
      @order = current_organ.organ_orders.find params[:order_id]
    end
  end
end

