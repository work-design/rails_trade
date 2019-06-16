class Trade::My::CartsController < Trade::My::BaseController

  def index
    @carts = current_user.carts
    if @carts.blank?
      current_user.carts.create(default: true)
    end
  end

  def create
    cart_item = current_cart.cart_items.find_by(good_id: params[:good_id], good_type: params[:good_type])
    params[:number] ||= 1
    if cart_item.present?
      cart_item.number = cart_item.number + params[:number].to_i
      cart_item.save
    else
      cart_item = current_cart.build(good_id: params[:good_id], good_type: params[:good_type])
      cart_item.save
    end

    @checked_ids = current_cart.checked_items.pluck(:id)

    render 'index'
  end

  def check
    if params[:add_id].present?
      @add = current_cart.find_by(id: params[:add_id])
      @add.update(checked: true)
    elsif params[:remove_id].present?
      @remove = current_cart.find_by(id: params[:remove_id])
      @remove.update(checked: false)
    end

    respond_to do |format|
      format.js
      format.json { render 'cart_item' }
    end
  end
  
  def show
  end

  def update
    @cart_item.update(number: params[:number])
  end

  def destroy
    @cart_item.update(status: :deleted, checked: false)
  end

  private
  def set_cart
    @cart = current_user.carts.find(params[:id])
  end

  def cart_item_params
    params.require(:cart_item).permit(
      id: [],
      single_price: [],
      amount: [],
      total_price: []
    )
  end

  

end
