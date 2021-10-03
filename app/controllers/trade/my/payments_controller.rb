module Trade
  class My::PaymentsController < My::BaseController
    before_action :set_payment, only: [:show, :edit, :update, :destroy]

    def index
      @payments = current_user.payments.page(params[:page])
    end

    def create
      @payment = Payment.new(payment_params)

      if params[:xx] == 'x' && @payment.save
        render 'create'
      else
        render :new, locals: { model: @payment }, status: :unprocessable_entity
      end
    end

    def show
    end

    def update
      @payment.assign_attributes(payment_params)

      unless @payment.save
        render :edit, locals: { model: @payment }, status: :unprocessable_entity
      end
    end

    def destroy
      @payment.destroy
    end

    private
    def set_payment
      @payment = current_user.payments.find(params[:id])
    end

    def payment_params
      params.fetch(:payment, {}).permit(
        :type,
        :card_id,
        :total_amount,
        payment_orders_attributes: [:order_id, :check_amount, :state]
      )
    end

  end
end
