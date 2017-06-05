class Admin::PaymentOrdersController < Admin::TheTradeController
  before_action :set_payment
  before_action :set_payment_order, only: [:show, :edit, :update, :destroy]

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
      render :new
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

  def set_payment
    @payment = Payment.find(params[:payment_id])
    @orders = Order.find_by buyer_id: @payment.payment_method.buyer_ids
  end

  def payment_order_params
    params.fetch(:payment_order, {}).permit(:order_id, :check_amount)
  end

end
