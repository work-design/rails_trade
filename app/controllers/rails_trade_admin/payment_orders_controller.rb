class RailsTradeAdmin::PaymentOrdersController < RailsTradeAdmin::BaseController
  before_action :set_payment
  before_action :set_payment_order, only: [:update, :cancel]
  after_action only: [:create] do
    mark_audits(Payment: [:payment_orders])
  end

  def new
    @payment_order = PaymentOrder.new
    @orders = @payment.pending_orders
  end

  def create
    @payment_order = @payment.payment_orders.build(payment_order_params)

    if @payment_order.confirm!
      respond_to do |format|
        format.js
      end
    else
      render 'create_fail'
    end
  end

  def update
    @payment_order.assign_attributes payment_order_params
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
