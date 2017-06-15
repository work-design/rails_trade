class PaymentsController < ApplicationController
  before_action :set_order

  def index
    @payment_orders = @order.payment_orders
  end

  private
  def set_order
    @order = Order.find(params[:order_id])
  end

end
