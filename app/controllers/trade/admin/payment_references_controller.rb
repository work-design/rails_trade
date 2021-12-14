module Trade
  class Admin::PaymentReferencesController < Admin::BaseController
    before_action :set_payment_method
    before_action :set_payment_reference, only: [:show, :edit, :update, :destroy]

    def index
      @payment_references = PaymentReference.page(params[:page])
    end

    def new
      @payment_reference = @payment_method.payment_references.build
    end

    def create
      @payment_reference = @payment_method.payment_references.build(payment_reference_params)

      if @payment_reference.save
        render 'create'
      else
        render :new, locals: { model: @payment_reference }, status: :unprocessable_entity
      end
    end

    private
    def set_payment_method
      @payment_method = PaymentMethod.find(params[:payment_method_id])
    end

    def set_payment_reference
      @payment_reference = PaymentReference.find(params[:id])
    end

    def payment_reference_params
      params.fetch(:payment_reference, {}).permit(
        :buyer_id
      )
    end

  end
end
