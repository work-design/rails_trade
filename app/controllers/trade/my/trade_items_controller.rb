class Trade::My::TradeItemsController < Trade::My::BaseController
  before_action :set_trade_item, only: [:show, :update, :destroy]
  
  def index
  
  end
  
  def create
    trade_item = current_cart.trade_items.find_by(good_id: params[:good_id], good_type: params[:good_type])
    params[:number] ||= 1
    if trade_item.present?
      trade_item.number = trade_item.number + params[:number].to_i
    else
      trade_item = current_cart.trade_items.build(good_id: params[:good_id], good_type: params[:good_type])
    end

    trade_item.init_amount
    trade_item.compute_promote
    trade_item.sum_amount
    trade_item.save

    @trade_items = current_cart.trade_items.page(params[:page])
    @checked_ids = current_cart.trade_items.checked.pluck(:id)
  
    redirect_to my_cart_url
  end

  def check
    if params[:add_id].present?
      @add = @cart.find_by(id: params[:add_id])
      @add.update(checked: true)
    elsif params[:remove_id].present?
      @remove = @cart.find_by(id: params[:remove_id])
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
    @trade_item.update(number: params[:number])
  end

  def destroy
    @trade_item.destroy
  end

  private
  def set_trade_item
    @trade_item = current_cart.trade_items.find(params[:id])
  end

  def set_additions
    if current_buyer
      @additions = CartService.new(buyer_type: current_buyer.class.name, buyer_id: current_buyer.id, myself: true)
    else
      @additions = CartService.new(session_id: session.id, myself: true)
    end
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
