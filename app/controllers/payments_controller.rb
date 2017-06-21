class PaymentsController < ApplicationController
  before_action :set_order

  def index
    @payment_orders = @order.payment_orders
  end

  def execute
    if @order.execute(params)
      redirect_to payment_success_orders_path, notice: "Order[#{order.uuid}] placed successfully"
    else
      redirect_to payment_fail_orders_path, alert: order.payment.error.inspect
    end
  end

  private
  def set_order
    @order = Order.find(params[:order_id])
  end

end
