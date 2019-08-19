class Trade::My::CartsController < Trade::My::BaseController
  
  def show
    @trade_items = current_cart.trade_items.page(params[:page])
    @checked_ids = current_cart.trade_items.checked.pluck(:id)
  end
  
  def total
  
  end
  
  def edit
  
  end
  
  def update
  
  end
  
  private
  def cart_params
    params.fetch(:cart, {}).permit(
      :buyer_type,
      :buyer_id
    )
  end
  
end
