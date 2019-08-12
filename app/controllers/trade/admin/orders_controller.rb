class Trade::Admin::OrdersController < Trade::Admin::BaseController
  before_action :set_order, only: [:show, :edit, :update, :refund, :destroy]
  skip_before_action :verify_authenticity_token, only: [:refresh]

  def index
    q_params = {}
    q_params.merge! default_params
    q_params.merge! params.permit(:id, :uuid, :user_id, :buyer_type, :buyer_id, :payment_status, :payment_type)

    @orders = Order.includes(:user).default_where(q_params).order(id: :desc).page(params[:page])
  end

  def payments
    @orders = Order.default_where(params.permit(:id, :payment_status)).default_where(params.fetch(:q, {}).permit(:uuid)).page(params[:page])
  end

  def new
    @order = Order.new(buyer_id: params[:buyer_id])
    if params[:cart_item_id]
      @order.migrate_from_cart_item(params[:cart_item_id])
    else
      @order.migrate_from_cart_items
    end

    respond_to do |format|
      format.html
      format.json { render json: @order }
    end
  end

  def refresh
    @order = Order.new(buyer_id: params[:buyer_id])
    @order.assign_attributes order_params

    if params[:cart_item_id]
      cart_item = CartItem.find(params[:cart_item_id])
      cart_item.update extra: @order.extra
      @order.migrate_from_cart_item(params[:cart_item_id])
    else
      @order.migrate_from_cart_items
    end

    respond_to do |format|
      format.js
      format.html
      format.json { render json: @order }
    end
  end

  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to admin_order_url(@order) }
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
      redirect_to @order
    else
      render :edit
    end
  end

  def refund
    @order.apply_for_refund

    respond_to do |format|
      format.html { redirect_to admin_orders_url(id: @order.id) }
      format.json { render json: @order.as_json(include: [:refunds]) }
    end
  end

  def destroy
    @order.destroy
    redirect_to admin_orders_url(buyer_id: @order.buyer_id)
  end

  private
  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    p = params.fetch(:order, {}).permit(
      :buyer_type,
      :buyer_id,
      :quantity,
      :payment_id,
      :payment_type,
      :address_id,
      :invoice_address_id,
      :amount,
      trade_items_attributes: [:deliver_on, :advance_price, :comment],
      trade_promotes_attributes: [:promote_id]
    )
    p.merge! default_form_params
  end

end
