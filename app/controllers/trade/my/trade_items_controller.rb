class Trade::My::TradeItemsController < Trade::My::BaseController
  before_action :set_trade_item, only: [:show, :update, :destroy]

  def index
    @trade_items = current_cart.trade_items.page(params[:page])
  end

  def create
    trade_item = current_cart.trade_items.find_or_initialize_by(good_id: params[:good_id], good_type: params[:good_type])
    params[:number] ||= 1
    trade_item.number = trade_item.number + params[:number].to_i

    trade_item.compute_promote
    trade_item.sum_amount
    trade_item.save

    @trade_items = current_cart.trade_items.page(params[:page])
    @checked_ids = current_cart.trade_items.checked.pluck(:id)
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
    @trade_item = current_cart.trade_items.find(params[:id])
  end

  def trade_item_params
    params.fetch(:trade_item, {}).permit(
      :number,
      :status
    )
  end

end
