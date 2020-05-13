class Trade::Board::CartsController < Trade::Board::BaseController
  before_action :set_cart

  def show
    q_params = {}
    if params[:address_id].present?
      current_cart.update address_id: params[:address_id]
    end
    @trade_items = @cart.trade_items.default_where(q_params).page(params[:page])
    @checked_ids = @cart.trade_items.default_where(q_params).checked.pluck(:id)
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
