module Trade
  class Admin::RefundsController < Admin::BaseController
    before_action :set_refund, only: [:show, :edit, :update, :destroy, :confirm, :deny]
    before_action :set_payment, only: [:new, :create]
    before_action :set_new_refund, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:order_id, :payment_id)

      @refunds = Refund.includes(:payment).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def confirm
      @refund.do_refund!(current_member)
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

    def set_filter_columns
      @filter_columns = set_filter_i18n(
        type: { type: 'dropdown', default: true },
        state: { type: 'dropdown', default: true },
        refund_uuid: { type: 'search', default: true }
      )
    end

    def refund_params
      params.fetch(:refund, {}).permit(
        :total_amount,
        :comment
      )
    end

  end
end
