module Trade
  class My::PaymentMethodsController < My::BaseController
    before_action :set_payment_method, only: [:show, :edit, :update, :destroy]

    def index
      @payment_methods = current_buyer.payment_methods
    end

    def new
      @payment_method = current_buyer.payment_methods.build
    end

    def create
      @payment_method = current_buyer.payment_methods.build(payment_method_params)

      unless @payment_method.detective_save

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
end
