class My::CartItemsController <  My::BaseController
  before_action :current_cart, only: [:index]
  before_action :set_cart_item, only: [:update, :destroy]
  skip_before_action :verify_authenticity_token, only: [:update]


  def index

  end

  def create
    cart_item = current_cart.where(good_id: params[:good_id], good_type: params[:good_type]).first
    params[:quantity] ||= 1
    if cart_item.present?
      cart_item.increment!(:quantity, params[:quantity].to_i)
    else
      cart_item = current_cart.build(good_id: params[:good_id], good_type: params[:good_type], quantity: params[:quantity], status: 'unpaid')
      cart_item.save
    end

    render 'index'
  end

  def update
    @cart_item.update(quantity: params[:quantity])
  end

  def destroy
    @cart_item.update(status: :deleted)
  end

  private

  def set_cart_item
    @cart_item = current_cart.find(params[:id])
  end

  def cart_item_params
    params.require(:cart_item).permit(id: [],
                                      single_price: [],
                                      amount: [],
                                      total_price: [])
  end

  def current_cart
    if defined?(current_buyer) && current_buyer
      @cart_items = current_buyer.cart_items.valid
    else
      @cart_items = CartItem.where(session_id: session.id).valid
    end
  end


end
