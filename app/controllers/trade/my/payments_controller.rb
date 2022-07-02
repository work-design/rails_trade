module Trade
  class My::PaymentsController < My::BaseController
    before_action :set_payment, only: [:show, :edit, :update, :destroy]
    before_action :set_new_payment, only: [:new, :create, :order_new, :order_create]
    before_action :set_order, only: [:order_new, :order_create]

    def index
      @payments = current_user.payments.page(params[:page])
    end

    def create
      if params[:xx] == 'x' && @payment.save
        render 'create'
      else
        render :new, locals: { model: @payment }, status: :unprocessable_entity
      end
    end

    def order_new
    end

    def order_create
      @payment = @order.payments.build(type: type, payment_uuid: payment_uuid)
      @payment.assign_attributes payment_params

      payment_order = @order.payment_orders.find(&:new_record?)
      payment_order.check_amount = @payment.total_amount
      @payment.save
    end

    private
    def set_payment
      if current_wallet
        @payment = current_wallet.wallet_payments.find(params[:id])
      end
    end

    def set_new_payment
      @payment = Payment.new(payment_params)
    end

    def set_order
      @order = Order.default_where(default_params).find params[:order_id]
    end

    def payment_params
      p = params.fetch(:payment, {}).permit(
        :type,
        :wallet_id,
        :total_amount,
        :proof,
        payment_orders_attributes: [:order_id, :check_amount, :state]
      )
      p.merge! default_form_params
    end

  end
end
