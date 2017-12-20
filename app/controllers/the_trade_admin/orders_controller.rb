class TheTradeAdmin::OrdersController < TheTradeAdmin::BaseController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  def index
    @orders = Order.default_where(params.permit(:uuid)).page(params[:page])
  end

  def payments
    @orders = Order.default_where(params.permit(:id, :payment_status)).default_where(params.fetch(:q, {}).permit(:uuid)).page(params[:page])
  end

  def new
    @order = Order.new(user_id: params[:user_id], assistant: true)
    if params[:cart_item_id]
      @order.migrate_from_cart_item(params[:cart_item_id])
    else
      @order.migrate_from_cart_items
      @order.init_with_default_serves
    end

    respond_to do |format|
      format.html
      format.json { render json: @order }
    end
  end

  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to admin_order_url(@order), notice: 'Order was successfully created.' }
        format.json { render json: @order, status: :created, location: @order }
      else
        format.html { render action: 'new' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  def update
    if @order.update(order_params)
      redirect_to @order, notice: 'Order was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @order.destroy
    redirect_to admin_orders_url(user_id: @order.user_id), notice: 'Order was successfully destroyed.'
  end

  private
  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.fetch(:order, {}).permit(:user_id, :quantity, :payment_id, :payment_type,
                                    :address_id, :invoice_address_id,
                                    order_items_attributes: [:cart_item_id, :deliver_on, :advance_payment, :comment],
                                    order_serves_attributes: [:serve_id, :serve_charge_id, :amount],
                                    order_promotes_attributes: [:promote_id, :promote_charge_id, :amount])
  end

end
