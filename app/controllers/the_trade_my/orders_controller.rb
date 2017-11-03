class TheTradeMy::OrdersController < TheTradeMy::BaseController
  before_action :set_buyer
  before_action :set_order, only: [:show, :edit, :update, :paypal_pay, :stripe_pay, :alipay_pay, :paypal_execute, :update_date, :refund, :destroy]

  def index
    @orders = @buyer.orders

    respond_to do |format|
      format.html
      format.json
    end
  end

  def new
    @order = Order.new
    @order.migrate_from_cart_items(params)

    respond_to do |format|
      format.html
      format.json { render json: @order }
    end
  end

  def create
    @order = @buyer.orders.build(order_params)
    respond_to do |format|
      if @order.save
        format.html { redirect_to my_order_url(@order), notice: 'Order was successfully created.' }
        format.json { render json: @order, status: :created, location: @order }
      else
        format.html { render action: "new" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def stripe_pay
    respond_to do |format|
      if @order.payment_status != 'all_paid'
        result = @order.stripe_charge(params)
        format.json { render json: { result: result } }
        format.html { redirect_to @order.approve_url }
      else
        format.json
        format.html { redirect_to my_orders_url }
      end
    end
  end

  def alipay_pay
    respond_to do |format|
      if @order.payment_status != 'all_paid'
        result = @order.create_alipay
        format.json { render json: { result: result } }
        format.html { redirect_to @order.approve_url }
      else
        format.json
        format.html { redirect_to my_orders_url }
      end
    end
  end

  def paypal_pay
    respond_to do |format|
      if @order.payment_status != 'all_paid' && @order.create_paypal_payment
        format.json
        format.html { redirect_to @order.approve_url }
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
        format.html { redirect_to payment_success_orders_path, notice: "Order[#{@order.uuid}] placed successfully" }
      else
        format.html { redirect_to payment_fail_orders_path, alert: @order.error.inspect }
        format.json {  }
      end
    end
  end

  def show

    respond_to do |format|
      format.html
      format.json { render json: @order }
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to action: 'edit', notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_date
    respond_to do |format|
      if @order.update(date_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @order.destroy

    respond_to do |format|
      format.html { redirect_to my_orders_url }
      format.json { head :no_content }
    end
  end

  def refund
    @order.apply_for_refund

    respond_to do |format|
      format.html { redirect_to my_orders_url }
      format.json { render json: @order.as_json(include: [:refunds]) }
    end
  end

  private
  def set_order
    @order = Order.find(params[:id])
  end

  def set_buyer
    @buyer = current_buyer
  end

  def order_params
    params.fetch(:order, {}).permit(:quantity, :payment_id, :payment_type, order_items_attributes: [:cart_item_id])
  end

  def date_params
    params[:order].permit(:order_on, :order_at)
  end

end
