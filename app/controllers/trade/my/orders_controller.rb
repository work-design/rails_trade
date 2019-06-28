class Trade::My::OrdersController < Trade::My::BaseController
  include ControllerOrderTypes
  before_action :set_order, only: [
    :show,
    :edit,
    :update,
    :refund,
    :edit_payment_type,
    :update_payment_type,
    :destroy,
  ]

  def index
    query_params = params.permit(:id, :payment_type, :payment_status)
    @orders = current_buyer.orders.default_where(query_params).order(id: :desc).page(params[:page])

    respond_to do |format|
      format.html
      format.html.wechat do
        self.class.include Wechat::Responder
        render 'index'
      end
      format.json
    end
  end

  def new
    @cart = current_user.carts.find params[:cart_id]
    @order = @cart.migrate_to_order

    respond_to do |format|
      format.html
      format.json { render json: @order }
    end
  end

  def refresh
    @order = current_buyer.orders.build(myself: true)
    @order.assign_attributes order_params
    @order.migrate_to_order

    respond_to do |format|
      format.js
      format.html
      format.json { render json: @order }
    end
  end

  def create
    @order = current_buyer.orders.build(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to my_order_url(@order) }
        format.json { render json: @order, status: :created, location: @order }
      else
        format.html { render action: 'new' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def direct
    @order = current_buyer.orders.build(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to my_orders_url(id: @order.id) }
        format.json { render json: @order, status: :created, location: @order }
      else
        format.html {
          redirect_back fallback_location: my_root_url
        }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def show

    respond_to do |format|
      format.html
      format.json { render json: @order }
    end
  end
  
  def wait
  end

  def edit
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @order }
    end
  end

  def update
    respond_to do |format|
      if @order.update(order_params)
        format.js
        format.html { redirect_to action: 'edit' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit_payment_type
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @order }
    end
  end

  def update_payment_type
    respond_to do |format|
      if @order.update(order_params)
        format.js
        format.html { redirect_to action: 'edit' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def refund
    @order.apply_for_refund

    respond_to do |format|
      format.html { redirect_to my_orders_url }
      format.json { render json: @order.as_json(include: [:refunds]) }
    end
  end

  def destroy
    @order.destroy

    respond_to do |format|
      format.html { redirect_to my_orders_url }
      format.json { head :no_content }
      format.js
    end
  end

  private
  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.fetch(:order, {}).permit(
      :quantity,
      :payment_id,
      :payment_type,
      :address_id,
      :invoice_address_id,
      :note,
      order_items_attributes: [:cart_item_id]
    )
  end

end
