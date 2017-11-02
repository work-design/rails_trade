class TheTradeAdmin::OrdersController < TheTradeAdmin::TheTradeController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  def index
    @orders = Order.page(params[:page])
  end

  def payments
    @orders = Order.default_where(params.permit(:id, :payment_status)).default_where(params.fetch(:q, {}).permit(:uuid)).page(params[:page])
  end

  def show
  end

  def new
    @order = Order.new
  end

  def edit
  end

  def create
    @order = Order.new(order_params)

    if @order.save
      redirect_to @order, notice: 'Order was successfully created.'
    else
      render :new
    end
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
    redirect_to orders_url, notice: 'Order was successfully destroyed.'
  end

  private
  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.fetch(:order, {})
  end

end
