module Trade
  class My::OrderPaymentsController < My::BaseController
    before_action :set_order
    before_action :set_new_payment, only: [:new, :create]
    after_action only: [:create] do
      mark_audits(instance: :@order, include: [:payment_orders])
    end

    def new
      @payment.total_amount = @order.unreceived_amount
    end

    private
    def set_order
      @order = Order.find params[:order_id]
    end

    def set_new_payment
      @payment = @order.payments.build(payment_params)
      @payment.init_uuid
      @payment.user = current_user
    end

    def model_name
      'payment'
    end

    def payment_params
      p = params.fetch(:payment, {}).permit(
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
        payment_orders_attributes: [:order_id, :check_amount, :state]
      )
      p.merge! default_form_params
    end

  end
end
