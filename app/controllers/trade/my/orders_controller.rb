class Trade::My::OrdersController < Trade::My::BaseController
  include ControllerOrderTypes
  #include Wechat::Responder
  before_action :set_order, only: [
    :show,
    :edit,
    :update,
    :refund,
    :edit_payment_type,
    :wait,
    :destroy,
  ]

  def index
    query_params = params.permit(:id, :payment_type, :payment_status)
    @orders = current_cart.orders.default_where(query_params).order(id: :desc).page(params[:page])
  end

  def new
    @order = current_cart.orders.build
  end

  def refresh
    @order = current_cart.orders.build(myself: true)
    @order.assign_attributes order_params
  end

  def create
    @order = current_cart.orders.build(order_params)

    if @order.save
      render 'create', locals: { return_to: my_order_url(@order) }
    else
      render :new, locals: { model: @order }, status: :unprocessable_entity
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
  end

  # todo part paid case
  def wait
    if @order.all_paid?
      render 'show'
    else
      render 'wait'
    end
  end

  def edit
  end

  def update
    @order.assign_attributes(order_params)

    if @order.save
      render 'update', locals: { return_to: my_order_url(@order) }
    else
      render :edit, locals: { model: @order }, status: :unprocessable_entity
    end
  end

  def edit_payment_type
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
      trade_items_attributes: {}
    )
  end

end
