class PaymentMethodsController < ApplicationController
  before_action :set_payment_method, only: [:show, :edit, :update, :destroy]

  def index
    @payment_methods = PaymentMethod.all
  end

  def show
  end

  def new
    @payment_method = PaymentMethod.new
  end

  def edit
  end

  def create
    @payment_method = PaymentMethod.new(payment_method_params)

    if @payment_method.save
      redirect_to @payment_method, notice: 'Payment method was successfully created.'
    else
      render :new
    end
  end

  def update
    if @payment_method.update(payment_method_params)
      redirect_to @payment_method, notice: 'Payment method was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @payment_method.destroy
    redirect_to payment_methods_url, notice: 'Payment method was successfully destroyed.'
  end

  private
  def set_payment_method
    @payment_method = PaymentMethod.find(params[:id])
  end

  def payment_method_params
    params.fetch(:payment_method, {})
  end

end
