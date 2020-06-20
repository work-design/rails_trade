class Trade::Board::CartsController < Trade::Board::BaseController

  def show
    q_params = {}
    if params[:address_id].present?
      current_cart.update address_id: params[:address_id]
    end
    @trade_items = current_cart.trade_items.default_where(q_params).page(params[:page])
    @checked_ids = current_cart.trade_items.default_where(q_params).checked.pluck(:id)
  end

  def add
    trade_item = current_cart.trade_items.find_or_initialize_by(good_id: params[:good_id], good_type: params[:good_type])
    if trade_item.persisted?
      params[:number] ||= 1
      trade_item.number += params[:number].to_i
    end
    trade_item.save

    @trade_items = current_cart.trade_items.page(params[:page])
    @checked_ids = current_cart.trade_items.checked.pluck(:id)

    render :show
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
