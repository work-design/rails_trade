class TheTradeMy::PaymentMethodsController < TheTradeMy::BaseController
  before_action :set_buyer, only: [:index, :new, :create]
  before_action :set_payment_method, only: [:show, :edit, :update, :destroy]

  def index
    @payment_methods = @buyer.payment_methods

    respond_to do |format|
      format.html { redirect_to my_orders_url }
      format.json { render json: @payment_methods.as_json(methods: 'kind') }
    end
  end

  def show
  end

  def new
    @payment_method = @buyer.payment_methods.build
  end

  def edit
  end

  def create
    @payment_method = @buyer.payment_methods.build(payment_method_params)

    if @payment_method.detective_save
      render json: @payment_method.as_json(methods: 'kind')
    else
      render :new
    end
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
    head :no_content
  end

  private
  def set_buyer
    @buyer = current_buyer
  end

  def set_payment_method
    @payment_method = PaymentMethod.find(params[:id])
  end

  def payment_method_params
    params.fetch(:payment_method, {}).permit(:account_name, :account_num, :bank, :buyer_id, :type, :token)
  end

end
