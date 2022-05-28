module Trade
  class Panel::RefundsController < Admin::RefundsController
    before_action :set_refund, only: [:show, :edit, :update, :confirm, :deny, :destroy]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:order_id, :payment_id)

      @refunds = Refund.includes(:order, :payment).default_where(q_params).page(params[:page])
    end

    def new
      @refund = @payment.refunds.build
    end

    def create
      @refund = Refund.new(refund_params)

      unless @refund.save
        render :new, locals: { model: @refund }, status: :unprocessable_entity
      end
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

    def refund_params
      params.fetch(:refund, {})
    end

  end
end
