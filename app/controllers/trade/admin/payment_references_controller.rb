module Trade
  class Admin::PaymentReferencesController < Admin::BaseController
    before_action :set_payment_method
    before_action :set_payment_reference, only: [:show, :edit, :update, :destroy]

    def index
      @payment_references = PaymentReference.page(params[:page])
    end

    def show
    end

    def new
      @payment_reference = @payment_method.payment_references.build
    end

    def edit
    end

    def create
      @payment_reference = @payment_method.payment_references.build(payment_reference_params)

      if @payment_reference.save
        render 'create'
      else
        render :new, locals: { model: @payment_reference }, status: :unprocessable_entity
      end
    end

    def update
      @payment_reference.assign_attributes payment_reference_params

      if @payment_reference.save
        render 'update'
      else
        render :edit, locals: { model: @payment_reference }, status: :unprocessable_entity
      end
    end

    def destroy
      @payment_reference.destroy
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
