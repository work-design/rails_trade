class Trade::Admin::PaymentsController < Trade::Admin::BaseController
  before_action :set_payment, only: [:show, :edit, :update, :analyze, :adjust, :destroy]

  def dashboard

  end

  def index
    q_params = {}
    q_params.merge! default_params
    q_params.merge! params.permit(:type, :state, :id, :buyer_identifier, :buyer_bank, :payment_uuid, 'buyer_name-like', 'payment_orders.state', 'orders.uuid')
    @payments = Payment.default_where(q_params).order(id: :desc).page(params[:page])
  end

  def show
  end

  def new
    @payment = Payment.new
    if params[:order_id]
      @order = Order.find params[:order_id]
      @payment.total_amount = @order.amount
    end
    @payment.payment_uuid = UidHelper.nsec_uuid('PAY')
  end

  def create
    if params[:order_id].present?
      @order = Order.find params[:order_id]
      @payment = @order.payments.build(payment_params.merge(creator_id: rails_role_user.id))
    else
      @payment = Payment.new(payment_params.merge(creator_id: rails_role_user.id))
    end

    if @payment.save
      redirect_to admin_payments_url
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @payment.update(payment_params)
      redirect_to admin_payments_url
    else
      render :edit
    end
  end

  def analyze
    @payment.analyze_payment_method
  end

  def adjust
    @payment.analyze_adjust_amount
    respond_to do |format|
      format.js
      format.html { redirect_to admin_payments_url }
    end
  end

  def destroy
    @payment.destroy
  end

  private
  def set_payment
    @payment = Payment.find(params[:id])
  end

  def payment_params
    p = params.fetch(:payment, {}).permit(
      :type,
      :payment_uuid,
      :total_amount,
      :fee_amount,
      :income_amount,
      :notified_at,
      :comment,
      :buyer_name,
      :buyer_identifier,
      :buyer_bank
    )
    p.merge! default_form_params
    p
  end

end
