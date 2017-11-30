class TheTradeAdmin::OrdersController < TheTradeAdmin::BaseController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  def index
    @orders = Order.default_where(params.permit(:uuid)).page(params[:page])
  end

  def payments
    @orders = Order.default_where(params.permit(:id, :payment_status)).default_where(params.fetch(:q, {}).permit(:uuid)).page(params[:page])
  end

  def new
    @order = Order.new
    cart_item_ids = params[:cart_item_ids].split(',')
    @order.migrate_from_cart_items(cart_item_ids)

    respond_to do |format|
      format.html
      format.json { render json: @order }
    end
  end

  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to my_order_url(@order), notice: 'Order was successfully created.' }
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
    redirect_to admin_orders_url, notice: 'Order was successfully destroyed.'
  end

  private
  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.fetch(:order, {})
  end

end
