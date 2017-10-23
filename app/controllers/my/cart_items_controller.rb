class My::CartItemsController <  My::BaseController
  before_action :get_cart_item, only: [:update_cart_items, :destroy]

  def create
    cart_item = current_cart_items.valid.where(product_id: params[:product_id], product_type: params[:type]).first
    if cart_item.present?
      amount = cart_item.amount.to_i + params[:amount].to_i
      cart_item.update(amount: amount)
    else
      cart_item = current_cart_items.build(product_id: params[:product_id], product_type: params[:type], amount: params[:amount])
      cart_item.save
    end

    render json: { cart_item_amount: current_cart_items.count }
  end

  def update_cart_items
    @cart_item.update(amount: params[:amount])
  end

  def destroy
    @cart_item.update(status: :deleted)
  end

  def change_is_use_courier
    session[:is_use_courier] = params[:is_use]
    if session[:is_use_courier] == '1'
      Thread.current[:is_use_courier] = true
      @shipping_fee = current_cart_items.shipping_fee(@current_nation, current_currency).format
    else
      Thread.current[:is_use_courier] = false
      @shipping_fee = current_cart_items.shipping_fee(@current_nation, current_currency).format
    end
  end

  def courier_account_set
    @company = Company.find params[:id]
    @company.courier_account = params[:courier_select]
    @company.account_number = params[:number]
    @company.save!
  end

  private

  def get_cart_item
    @cart_item = CartItem.find(params[:id])
  end

  def cart_item_params
    params.require(:cart_item).permit(id: [],
                                      single_price: [],
                                      amount: [],
                                      total_price: [])
  end


end
