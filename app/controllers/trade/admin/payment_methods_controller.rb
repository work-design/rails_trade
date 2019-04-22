class Trade::Admin::PaymentMethodsController < Trade::Admin::BaseController
  before_action :set_payment_method, only: [:show, :edit, :update, :verify, :merge_from, :destroy]

  def index
    @payment_methods = PaymentMethod.includes(:payment_references).default_where(query_params).page(params[:page])
  end

  def unverified
    @payment_methods = PaymentMethod.includes(:payment_references).unscoped.where(verified: [false, nil]).default_where(query_params).page(params[:page]).references(:payment_references)
  end

  def mine
    default_params = {
      creator_id: the_audit_user.id
    }
    @payment_methods = PaymentMethod.includes(:payment_references).default_where(default_params).page(params[:page])
  end

  def new
    @payment_method = PaymentMethod.new

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @payment_method = PaymentMethod.new(payment_method_params.merge(verified: true, creator_id: the_audit_user.id))

    respond_to do |format|
      if @payment_method.save
        format.html { redirect_to admin_payment_methods_url }
        format.js
      else
        format.html { render :new }
        format.js
      end
    end
  end

  def show
  end

  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    if @payment_method.update(payment_method_params)
      redirect_to admin_payment_methods_url
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
    redirect_to admin_payment_methods_url
  end

  private
  def query_params
    query_params = { myself: false }.with_indifferent_access
    query_params.merge! params.fetch(:q, {}).permit(:account_name, :account_num, :bank, 'buyers.name-like')
    query_params.merge! params.permit(:id, :myself)
  end

  def set_payment_method
    @payment_method = PaymentMethod.unscoped.find(params[:id])
  end

  def payment_method_params
    p = params.fetch(:payment_method, {}).permit(
      :type,
      :account_name,
      :account_num,
      :bank,
      :verified
    )
    p.merge! myself: false
  end

  def payment_reference_params
    params.fetch(:payment_reference, {}).permit(
      :account_type,
      :account_id
    )
  end

end
