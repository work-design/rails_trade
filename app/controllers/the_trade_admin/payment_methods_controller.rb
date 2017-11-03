class TheTradeAdmin::PaymentMethodsController < TheTradeAdmin::BaseController
  before_action :set_payment_method, only: [:show, :edit, :update, :verify, :merge_from, :destroy]

  def index
    @payment_methods = PaymentMethod.includes(:payment_references).default_where(params.permit(:id)).default_where(params.fetch(:q, {}).permit(:account_name, :account_num, :bank)).page(params[:page])
  end

  def unverified
    @payment_methods = PaymentMethod.includes(:payment_references).unscoped.where(verified: [false, nil]).page(params[:page]).references(:payment_references)
  end

  def new
    @payment_method = PaymentMethod.new
  end

  def create
    @payment_method = PaymentMethod.new(payment_method_params.merge(verified: true))

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

  def verify
    @payment_method.update(verified: true)

    redirect_back fallback_location: unverified_admin_payment_methods_url
  end

  def merge_from
    @payment_method.merge_from(params[:other_id])

    redirect_back fallback_location: unverified_admin_payment_methods_url
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
    @payment_method = PaymentMethod.unscoped.find(params[:id])
  end

  def payment_method_params
    params.fetch(:payment_method, {}).permit(:account_name, :account_num, :bank, :verified)
  end

  def payment_reference_params
    params.fetch(:payment_reference, {}).permit(:account_type, :account_id)
  end

end
