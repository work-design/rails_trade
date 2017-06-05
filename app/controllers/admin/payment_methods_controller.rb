class Admin::PaymentMethodsController < Admin::TheTradeController
  before_action :set_payment_method, only: [:show, :edit, :update, :destroy]

  def index
    @payment_methods = PaymentMethod.default_where(params.permit(:id)).page(params[:page])
  end

  def new
    @payment_method = PaymentMethod.new
  end

  def create
    @payment_method = PaymentMethod.new(payment_method_params)

    if @payment_method.save
      redirect_to admin_payment_methods_url, notice: 'Payment method was successfully created.'
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @payment_method.update(payment_method_params)
      redirect_to admin_payment_methods_url, notice: 'Payment method was successfully updated.'
    else
      render :edit
    end
  end

  def edit_references

  end

  def update_references

  end

  def destroy
    @payment_method.destroy
    redirect_to admin_payment_methods_url, notice: 'Payment method was successfully destroyed.'
  end

  private
  def set_payment_method
    @payment_method = PaymentMethod.find(params[:id])
  end

  def payment_method_params
    params.fetch(:payment_method, {}).permit(:bank_num, :bank_name)
  end

  def payment_reference_params
    params.fetch(:payment_reference, {}).permit(:account_type, :account_id)
  end

end
