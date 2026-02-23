module Trade
  class Admin::RefundOrdersController < Admin::BaseController
    before_action :set_order

    def index
      @refund_orders = @order.refund_orders.page(params[:page])
    end

    private
    def set_order
      @order = Order.find(params[:order_id])
    end

  end
end
