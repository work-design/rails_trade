class Trade::Admin::CartsController < Trade::Admin::BaseController
  before_action :set_cart

  def index
  end

  def single
  end

  def total
  end

  def show
  end

  def new
    @cart_serve = @cart_item.cart_serves.find_or_initialize_by(serve_id: params[:serve_id])
    @serve_charge = @cart_item.get_charge(@cart_serve.serve)
  end

  def create
    @cart_item_serve = @cart_item.cart_item_serves.find_or_initialize_by(serve_id: cart_item_serve_params[:serve_id])
    @cart_item_serve.assign_attributes cart_item_serve_params

    @serve_charge = @cart_item.get_charge(@cart_item_serve.serve)
    @serve_charge.subtotal = @cart_item_serve.price

    respond_to do |format|
      if @cart_item_serve.save
        @cart_item.cart_item_serves.reload
        format.js
        format.html { redirect_to @cart_item_serve }
      else
        format.js
        format.html { render :new }
      end
    end
  end

  def add
    @cart_item_serve = @cart_item.cart_item_serves.find_or_initialize_by(serve_id: params[:serve_id])

    @serve_charge = @cart_item.get_charge(@cart_item_serve.serve)
    @cart_item_serve.price = @serve_charge.default_subtotal
    @cart_item_serve.save
  end

  def destroy
    @cart_item_serve = CartItemServe.find(params[:id])
    @serve_charge = @cart_item.get_charge(@cart_item_serve.serve)
    @cart_item_serve.destroy
  end

  private
  def set_cart
    @cart = Cart.find params[:id]
  end

  def cart_item_serve_params
    params.fetch(:cart_item_serve, {}).permit(
      :serve_id,
      :price
    )
  end

end
