class Trade::Board::CartsController < Trade::Board::BaseController

  def index
    q_params = {}
    q_params.merge! default_params

    @carts = current_user.carts.includes(:trade_items).default_where(q_params).page(params[:page])
  end

  def show
    if params[:address_id].present?
      current_cart.update address_id: params[:address_id]
    end
    @trade_items = current_cart.trade_items.where(good_type: 'Custom').page(params[:page])
    @checked_ids = current_cart.trade_items.where(good_type: 'Custom').checked.pluck(:id)
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
