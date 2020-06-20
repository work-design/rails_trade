class Trade::Board::TradeItemsController < Trade::Board::BaseController
  before_action :set_trade_item, only: [:show, :update, :destroy]

  def create
    trade_item = current_cart.trade_items.find_or_initialize_by(good_id: params[:good_id], good_type: params[:good_type])
    trade_item.assign_attributes trade_item_params
    if trade_item.persisted?
      params[:number] ||= 1
      trade_item.number += params[:number].to_i
    end
    trade_item.compute_promote
    trade_item.sum_amount
    trade_item.save

    @trade_items = @cart.trade_items.page(params[:page])
    @checked_ids = @cart.trade_items.checked.pluck(:id)

    redirect_to my_cart_url
  end

  def show
  end

  def update
    @trade_item.assign_attributes(trade_item_params)
    @trade_item.save
  end

  def check
    @trade_item.check
  end

  def uncheck
    @trade_item.uncheck
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
      :number
    )
  end

end
