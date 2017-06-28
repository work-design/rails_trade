class Admin::OrderPaymentsController < Admin::TheTradeController
  before_action :set_order
  before_action :set_payment_order, only: [:destroy]

  def new
    @payment_order = PaymentOrder.new
  end

  def create
    @payment_order = @payment.payment_orders.build(payment_order_params)

    if @payment_order.save
      respond_to do |format|
        format.js
      end
    else
      render 'create_fail'
    end
  end

  def destroy
    @payment_order.destroy
    respond_to do |format|
      format.js
    end
  end

  private
  def set_payment_order
    @payment_order = PaymentOrder.find(params[:id])
  end

  def set_order
    @order = Order.find(params[:order_id])
    @payments = @order.pending_payments
  end

  def payment_order_params
    params.fetch(:payment_order, {}).permit(:payment_id, :check_amount)
  end

end
