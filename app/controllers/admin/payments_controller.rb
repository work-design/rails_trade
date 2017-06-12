class Admin::PaymentsController < Admin::TheTradeController
  before_action :set_payment, only: [:show, :edit, :update, :analyze, :destroy]


  def dashboard
  end

  def index
    @payments = Payment.default_where(params.permit(:type, :id)).page(params[:page])
  end

  def show
  end

  def new
    @payment = Payment.new
  end

  def create
    @payment = Payment.new(payment_params)

    if @payment.save
      redirect_to admin_payments_url, notice: 'Payment was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @payment.update(payment_params)
      redirect_to admin_payments_url, notice: 'Payment was successfully updated.'
    else
      render :edit
    end
  end

  def analyze
    @payment.analyze_payment_method

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @payment.destroy
    redirect_to admin_payments_url, notice: 'Payment was successfully destroyed.'
  end

  private
  def set_payment
    @payment = Payment.find(params[:id])
  end

  def payment_params
    p = params.fetch(:payment, {}).permit(:total_amount,
                                          :fee_amount,
                                          :notified_at,
                                          :comment,
                                          :buyer_name,
                                          :buyer_identifier,
                                          :buyer_bank
    )
    p.reverse_merge(type: 'BankPayment')
  end

end
