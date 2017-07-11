class Admin::RefundsController < Admin::TheTradeController
  before_action :set_payment
  before_action :set_refund, only: [:show, :edit, :update, :destroy]

  def index
    @refunds = Refund.all
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

  def destroy
    @refund.destroy
    redirect_to refunds_url, notice: 'Refund was successfully destroyed.'
  end

  private
  def set_payment
    @payment = Payment.find params[:payment_id]
  end

  def set_refund
    @refund = Refund.find(params[:id])
  end

  def refund_params
    params.fetch(:refund, {})
  end

end
