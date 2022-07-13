module Trade
  class Admin::OrderPaymentsController < Admin::BaseController
    before_action :set_payment_order, only: [:destroy]
    after_action only: [:create] do
      mark_audits(instance: :@order, include: [:payment_orders])
    end



    private
    def set_payment_order
      @payment_order = PaymentOrder.find(params[:id])
    end

    def payment_order_params
      params.fetch(:payment_order, {}).permit(
        :payment_id,
        :check_amount
      )
    end

  end
end
