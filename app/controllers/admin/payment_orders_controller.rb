class Admin::PaymentOrdersController < Admin::TheTradeController
  before_action :set_payment
  before_action :set_payment_order, only: [:update, :cancel]

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

  def update
    if @payment_order.confirm!
      respond_to do |format|
        format.js
      end
    else
      render 'create_fail'
    end
  end

  def cancel
    @payment_order.revert_confirm!
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
  end

  def payment_order_params
    params.fetch(:payment_order, {}).permit(:order_id, :check_amount).merge(state: 'confirmed')
  end

end
