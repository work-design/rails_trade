class Trade::My::CartsController < Trade::My::BaseController
  
  def show
    @trade_items = current_cart.trade_items.page(params[:page])
    @checked_ids = current_cart.trade_items.checked.pluck(:id)
  end
  
  def create
    trade_item = current_cart.trade_items.find_by(good_id: params[:good_id], good_type: params[:good_type])
    params[:number] ||= 1
    if trade_item.present?
      trade_item.number = trade_item.number + params[:number].to_i
      trade_item.save
    else
      trade_item = current_cart.build(good_id: params[:good_id], good_type: params[:good_type])
      trade_item.save
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
      format.json { render 'trade_item' }
    end
  end
  
  

  def update
    @trade_item.update(number: params[:number])
  end

  def destroy
    @trade_item.update(status: :deleted, checked: false)
  end

  private
  def trade_item_params
    params.require(:trade_item).permit(
      id: [],
      single_price: [],
      amount: [],
      total_price: []
    )
  end

  

end
