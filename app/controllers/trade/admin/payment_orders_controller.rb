module Trade
  class Admin::PaymentOrdersController < Admin::BaseController
    before_action :set_payment
    before_action :set_payment_order, only: [:update, :refund, :confirm, :cancel]
    before_action :set_new_payment_order, only: [:new, :create]
    after_action only: [:create, :cancel, :update] do
      mark_audits(instance: :@payment_order, include: [:payment, :order])
    end

    def index
      @payment_orders = @payment.payment_orders
    end

    def confirmable
      @payment_orders = @payment.payment_orders
    end

    def new
      @payment_order = PaymentOrder.new
      @orders = @payment.pending_orders
    end

    def create
      @payment_order.state = 'confirmed'
      @payment.checked_amount += @payment_order.payment_amount
      if @payment.save
        render 'create'
      else
        render 'create_fail'
      end
    end

    def refund
      @payment_order.refund_by_payment
    end

    def confirm
      @payment_order.confirmed!
    end

    def cancel
      @payment_order.state = 'init'
      @payment_order.save
    end

    private
    def set_payment
      @payment = Payment.find(params[:payment_id])
    end

    def set_payment_order
      @payment_order = PaymentOrder.find(params[:id])
    end

    def set_new_payment_order
      @payment_order = @payment.payment_orders.build(payment_order_params)
    end

    def payment_order_params
      params.fetch(:payment_order, {}).permit(
        :order_id,
        :order_amount,
        :payment_amount
      )
    end

  end
end
