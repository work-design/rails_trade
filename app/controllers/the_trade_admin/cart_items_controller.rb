class TheTradeAdmin::CartItemsController < TheTradeAdmin::BaseController
  before_action :current_cart, only: [:index, :create, :only, :total]
  before_action :set_cart_item, only: [:update, :destroy]
  skip_before_action :verify_authenticity_token, only: [:total]

  def index
    @checked_ids = @cart_items.checked.pluck(:id)
    @additions = CartItem.checked_items(user_id: @user&.id, buyer_id: params[:buyer_id])
  end

  def only
    unless params[:good_type] && params[:good_id]
      redirect_back(fallback_location: admin_cart_items_url, notice: 'Need Good type and Good ID') and return
    end

    good = params[:good_type].safe_constantize&.find_by(id: params[:good_id])
    if good.respond_to?(:user_id)
      @user = User.find good.user_id
      @buyer = @user.buyer
      @cart_items = CartItem.where(good_type: params[:good_type], good_id: params[:good_id], user_id: good.user_id)
    end

    @cart_item = @cart_items.where(good_id: params[:good_id], good_type: params[:good_type]).first
    if @cart_item.present?
      params[:quantity] ||= 0
      @cart_item.checked = true
      @cart_item.quantity = @cart_item.quantity + params[:quantity].to_i
      @cart_item.save
    else
      @cart_item = @cart_items.build(good_id: params[:good_id], good_type: params[:good_type], quantity: params[:quantity])
      @cart_item.checked = true
      @cart_item.save
    end

    @additions = @cart_item.total

    render 'only'
  end

  def create
    cart_item = @cart_items.unscope(where: :status).where(good_id: params[:good_id], good_type: params[:good_type]).first
    if cart_item.present?
      params[:quantity] ||= 0
      cart_item.checked = true
      cart_item.status = 'pending'
      cart_item.quantity = cart_item.quantity + params[:quantity].to_i
      cart_item.save
    else
      cart_item = @cart_items.build(good_id: params[:good_id], good_type: params[:good_type], quantity: params[:quantity], myself: false)
      cart_item.checked = true
      cart_item.save
    end

    @checked_ids = @cart_items.checked.pluck(:id)
    @additions = CartItem.checked_items(user_id: @user_id, buyer_id: params[:buyer_id])

    render 'index'
  end

  def total
    if params[:add_id].present?
      @add = @cart_items.find_by(id: params[:add_id])
      @add.update(checked: true)
    elsif params[:remove_id].present?
      @remove = @cart_items.find_by(id: params[:remove_id])
      @remove.update(checked: false)
    end

    @additions = CartItem.checked_items(user_id: @user&.id, buyer_id: params[:buyer_id])

    response.headers['X-Request-URL'] = request.url
  end

  def doc

  end

  def update
    @cart_item.update(quantity: params[:quantity])
    @additions = CartItem.checked_items(user_id: @cart_item.user_id, buyer_id: @cart_item.buyer_id)
  end

  def destroy
    @cart_item = CartItem.find params[:id]
    @cart_item.destroy
    @additions = CartItem.checked_items(user_id: @cart_item.user_id, buyer_id: @cart_item.buyer_id)
  end

  private
  def set_cart_item
    @cart_item = CartItem.find(params[:id])
    if @cart_item.user_id
      @cart_items = CartItem.where(user_id: @cart_item.user_id)
    else
      @cart_items = CartItem.where(buyer_id: @cart_item.buyer_id)
    end
  end

  def cart_item_params
    params.require(:cart_item).permit(id: [],
                                      single_price: [],
                                      amount: [],
                                      total_price: [])
  end

  def current_cart
    if params[:user_id].present?
      @cart_items = CartItem.where(user_id: params[:user_id])
      @user = User.find params[:user_id]
      @buyer = @user.buyer
    elsif params[:buyer_id].present?
      @buyer = Buyer.find params[:buyer_id]
      @cart_items = CartItem.where(buyer_id: params[:buyer_id])
    else
      @cart_items = CartItem.none
    end
    @cart_items = @cart_items.pending.default_where(params.permit(:good_type, :myself)).page(params[:page])
  end

end
