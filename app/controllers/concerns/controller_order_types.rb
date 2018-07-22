module ControllerOrderTypes
  extend ActiveSupport::Concern

  included do
    before_action :set_order, only: [:paypal_pay, :stripe_pay, :alipay_pay, :paypal_execute]
  end

  def stripe_pay
    if @order.payment_status != 'all_paid'
      @order.stripe_charge(params)
    end

    respond_to do |format|
      if @order.errors.blank?
        format.json { render json: { result: @order } }
        format.html { redirect_to @order.approve_url }
      else
        format.json {
          process_errors(@order)
        }
        format.html { redirect_to my_orders_url }
      end
    end
  end

  def alipay_pay
    respond_to do |format|
      if @order.payment_status != 'all_paid'
        format.json {
          result = @order.alipay_prepay
          render json: { result: result }
        }
        format.html {
          redirect_to @order.alipay_prepay_url
        }
      else
        format.json
        format.html { redirect_to my_orders_url }
      end
    end
  end

  def paypal_pay
    respond_to do |format|
      if @order.payment_status != 'all_paid'
        result = @order.paypal_prepay
        format.json
        format.html { redirect_to result }
      else
        format.json
        format.html { redirect_to my_orders_url }
      end
    end
  end

  def paypal_execute
    respond_to do |format|
      if @order.paypal_execute(params)
        format.json {  }
        format.html { redirect_to my_order_url(@order.id), notice: "Order[#{@order.uuid}] placed successfully" }
      else
        format.html { redirect_to my_orders_url, alert: @order.error.inspect }
        format.json {  }
      end
    end
  end

end