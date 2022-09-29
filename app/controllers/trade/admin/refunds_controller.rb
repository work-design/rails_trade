module Trade
  class Admin::RefundsController < Admin::BaseController
    before_action :set_payment
    before_action :set_refund, only: [:show, :edit, :update, :destroy, :confirm, :deny]
    before_action :set_new_refund, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:order_id, :payment_id)

      @refunds = Refund.includes(:order, :payment).default_where(q_params).page(params[:page])
    end

    def confirm
      @refund.do_refund
      @refund.operator = current_member
      @refund.refunded_at = Time.current

      @refund.save
    end

    def deny
      @refund.state = 'denied'
      @refund.operator = current_member

      @refund.save
    end

    private
    def set_refund
      @refund = Refund.find(params[:id])
    end

    def set_payment
      @payment = Payment.find params[:payment_id]
    end

    def set_new_refund
      @refund = @payment.refunds.build(refund_params)
    end

    def refund_params
      params.fetch(:refund, {}).permit(
        :total_amount
      )
    end

  end
end
