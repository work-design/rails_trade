class Trade::Admin::RefundsController < Trade::Admin::BaseController
  before_action :set_refund, only: [:show, :edit, :update, :confirm, :deny, :destroy]

  def index
    @refunds = Refund.includes(:order, :payment).default_where(params.permit(:order_id, :payment_id)).page(params[:page])
  end

  def show
  end

  def new
    @refund = @payment.refunds.build
  end

  def edit
  end

  def create
    @refund = Refund.new(refund_params)

    if @refund.save
      redirect_to @refund, notice: 'Refund was successfully created.'
    else
      render :new
    end
  end

  def update
    if @refund.update(refund_params)
      redirect_to @refund, notice: 'Refund was successfully updated.'
    else
      render :edit
    end
  end

  def confirm
    @refund.do_refund(operator_id: current_user.id, operator_type: current_user.class.name)
    redirect_to admin_refunds_url(order_id: @refund.order_id)
  end

  def deny
    @refund.deny_refund(operator_id: current_user.id, operator_type: current_user.class.name)
    redirect_to admin_refunds_url(order_id: @refund.order_id)
  end

  def destroy
    @refund.destroy
    redirect_to admin_refunds_url, notice: 'Refund was successfully destroyed.'
  end

  private
  def set_refund
    @refund = Refund.find(params[:id])
  end

  def refund_params
    params.fetch(:refund, {})
  end

end
