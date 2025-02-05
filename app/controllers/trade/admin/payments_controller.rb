module Trade
  class Admin::PaymentsController < Admin::BaseController
    before_action :set_payment, only: [
      :show, :edit, :update, :destroy, :actions,
      :analyze, :adjust, :print
    ]
    before_action :set_new_payment, only: [:new, :create, :confirm, :order_new, :order_create]

    def dashboard
    end

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:type, :state, :id, :buyer_identifier, :buyer_bank, :payment_uuid, 'buyer_name-like', 'payment_orders.state', 'orders.uuid')

      @payments = Payment.includes(:payment_method, :payment_orders).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def uncheck
      q_params = {}
      q_params.merge! default_params

      @payments = Payment.includes(:user, :payment_orders).to_check.default_where(q_params).order(id: :desc).page(params[:page])
    end

    def confirm
      @payment.confirm!(payment_params)
    end

    def analyze
      @payment.analyze_payment_method
    end

    def adjust
      @payment.analyze_adjust_amount
    end

    def print
      @payment.print
    end

    private
    def set_payment
      @payment = Payment.find(params[:id])
    end

    def set_new_payment
      @payment = Payment.new(payment_params)
    end

    def payment_params
      p = params.fetch(:payment, {}).permit(
        :type,
        :wallet_id,
        :payment_uuid,
        :total_amount,
        :fee_amount,
        :income_amount,
        :notified_at,
        :comment,
        :buyer_name,
        :buyer_identifier,
        :buyer_bank,
        :proof,
        :adjust_amount,
        payment_orders_attributes: [:order_id, :order_amount, :payment_amount, :state]
      )
      p.merge! default_form_params
    end

  end
end
