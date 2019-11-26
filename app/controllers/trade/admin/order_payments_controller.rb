class Trade::Admin::OrderPaymentsController < Trade::Admin::BaseController
  before_action :set_order
  before_action :set_payment_order, only: [:destroy]
  after_action only: [:create] do
    mark_audits(instance: :@order, include: [:payment_orders])
  end

  def index
    @payment_orders = @order.payment_orders
  end

  def new
    @payment_order = PaymentOrder.new
    @payments = @order.pending_payments
  end

  def create
    @payment_order = @order.payment_orders.build(payment_order_params)
    @order = @payment_order.order

    if @payment_order.save
      respond_to do |format|
        format.js
      end
    else
      render 'create_fail'
    end
  end

  def destroy
    if @payment_order.init?
      @payment_order.destroy
    end
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
  end

  def payment_order_params
    params.fetch(:payment_order, {}).permit(
      :payment_id,
      :check_amount
    )
  end

end
