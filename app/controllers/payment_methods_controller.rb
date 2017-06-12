class PaymentMethodsController < ApplicationController
  before_action :set_buyer
  before_action :set_payment_method, only: [:show, :edit, :update, :destroy]

  def index
    @payment_methods = @buyer.payment_methods
  end

  def show
  end

  def new
    @payment_method = PaymentMethod.new
  end

  def edit
  end

  def create
    @payment_method = @buyer.payment_methods.build(payment_method_params)

    if @payment_method.detective_save
      render 'create'
    else
      render :new
    end
  end

  def update
    @payment_method.assign_attributes(payment_method_params)
    if @payment_method.detective_save
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
  def set_buyer
    @buyer = Buyer.find params[:buyer_id]
  end

  def set_payment_method
    @payment_method = PaymentMethod.find(params[:id])
  end

  def payment_method_params
    params.fetch(:payment_method, {}).permit(:account_name, :account_num, :bank)
  end

end
