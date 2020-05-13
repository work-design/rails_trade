class Trade::Board::TradeItemsController < Trade::Board::BaseController
  before_action :set_trade_item, only: [:show, :update, :destroy]


  def create
    @cart = current_user.carts.find_or_create_by(organ_id: params[:organ_id])
    trade_item = @cart.trade_items.find_or_initialize_by(good_id: params[:good_id], good_type: params[:good_type])
    trade_item.assign_attributes trade_item_params
    trade_item.save

    @trade_items = @cart.trade_items.page(params[:page])
    @checked_ids = @cart.trade_items.checked.pluck(:id)
  end

  def show
  end

  def update
    @trade_item.assign_attributes(trade_item_params)
    @trade_item.save
  end

  def destroy
    @trade_item.destroy
  end

  private
  def set_trade_item
    @trade_item = TradeItem.find params[:id]
    #@trade_item = current_cart.trade_items.find(params[:id])
  end

  def trade_item_params
    params.fetch(:trade_item, {}).permit(
      :number,
      :status
    )
  end

end
