class Trade::Admin::PaymentMethodsController < Trade::Admin::BaseController
  before_action :set_payment_method, only: [:show, :edit, :update, :verify, :merge_from, :destroy]

  def index
    query_params = {
      myself: false
    }
    query_params.merge! params.permit(:id, :myself, :account_name, :account_num, :bank, 'buyers.name-like')

    @payment_methods = PaymentMethod.includes(:payment_references).default_where(query_params).page(params[:page])
  end

  def unverified
    q_params = {}
    
    @payment_methods = PaymentMethod.includes(:payment_references).unscoped.where(verified: [false, nil]).default_where(q_params).page(params[:page]).references(:payment_references)
  end

  def mine
    default_params = {
      creator_id: the_audit_user.id
    }
    @payment_methods = PaymentMethod.includes(:payment_references).default_where(default_params).page(params[:page])
  end

  def new
    @payment_method = PaymentMethod.new
  end

  def create
    @payment_method = PaymentMethod.new(payment_method_params.merge(verified: true, creator_id: the_audit_user.id))

    unless @payment_method.save
      render :new, locals: { model: @payment_method }, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @payment_method.assign_attributes(payment_method_params)

    unless @payment_method.save
      render :edit, locals: { model: @payment_method }, status: :unprocessable_entity
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
  end

  private
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
