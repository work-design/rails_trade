class RailsTradeMy::PaymentMethodsController < RailsTradeMy::BaseController
  before_action :set_payment_method, only: [:show, :edit, :update, :destroy]

  def index
    @payment_methods = current_buyer.payment_methods

    respond_to do |format|
      format.html {

      }
      format.json { render json: @payment_methods.as_json(methods: 'kind') }
    end
  end

  def new
    @payment_method = current_buyer.payment_methods.build
  end

  def create
    @payment_method = current_buyer.payment_methods.build(payment_method_params)

    respond_to do |format|
      if @payment_method.detective_save
        format.html
        format.json { render json: @payment_method.as_json(methods: 'kind') }
        format.js
      else
        format.html { render :new }
        format.json
        format.js
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    @payment_method.assign_attributes(payment_method_params)
    if @payment_method.detective_save
      render 'update'
    else
      render :edit
    end
  end

  def destroy
    @payment_method.destroy

    respond_to do |format|
      format.html { head :no_cont }
      format.js
    end
  end

  private
  def set_payment_method
    @payment_method = PaymentMethod.find(params[:id])
  end

  def payment_method_params
    _params = params.fetch(:payment_method, {}).permit(
      :account_name,
      :account_num,
      :bank,
      :buyer_id,
      :type,
      :token
    )
    _params.merge(verified: true, myself: true)
  end

end
