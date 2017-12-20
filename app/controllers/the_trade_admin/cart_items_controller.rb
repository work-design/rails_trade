class TheTradeAdmin::CartItemsController < TheTradeAdmin::BaseController
  before_action :current_cart, only: [:index, :create, :only, :total]
  before_action :set_cart_item, only: [:update, :destroy]
  skip_before_action :verify_authenticity_token, only: [:total]

  def index
    @checked_ids = @cart_items.checked.pluck(:id)
    @additions = CartItem.checked_items(good_type: params[:good_type], good_id: params[:good_id], user_id: @user_id, buyer_id: params[:buyer_id], assistant: true)
  end

  def only
    cart_item = @cart_items.where(good_id: params[:good_id], good_type: params[:good_type], assistant: true).first
    if cart_item.present?
      params[:quantity] ||= 0
      cart_item.checked = true
      cart_item.quantity = cart_item.quantity + params[:quantity].to_i
      cart_item.save
    else
      cart_item = @cart_items.build(good_id: params[:good_id], good_type: params[:good_type], quantity: params[:quantity], assistant: true)
      cart_item.checked = true
      cart_item.save
    end
    @user.cart_items.where(assistant: true).where.not(id: cart_item.id).update_all(checked: false)

    @checked_ids = @cart_items.checked.pluck(:id)
    @additions = CartItem.checked_items(user_id: @user&.id, buyer_id: params[:buyer_id], assistant: true)

    redirect_to action: 'index', good_type: params[:good_type], good_id: params[:good_id]
  end

  def create
    cart_item = @cart_items.where(good_id: params[:good_id], good_type: params[:good_type], assistant: true).first
    if cart_item.present?
      params[:quantity] ||= 0
      cart_item.checked = true
      cart_item.quantity = cart_item.quantity + params[:quantity].to_i
      cart_item.save
    else
      cart_item = @cart_items.build(good_id: params[:good_id], good_type: params[:good_type], quantity: params[:quantity], assistant: true)
      cart_item.checked = true
      cart_item.save
    end

    @checked_ids = @cart_items.checked.pluck(:id)
    @additions = CartItem.checked_items(user_id: @user_id, buyer_id: params[:buyer_id], assistant: true)

    render 'index'
  end

  def total
    @checked_ids = params[:cart_item_ids].to_s.split(',').map { |id| id.to_i }
    @unchecked_ids = @cart_items.pluck(:id) - @checked_ids

    CartItem.where(id: @checked_ids).update_all(checked: true) if @checked_ids.size > 0
    CartItem.where(id: @unchecked_ids).update_all(checked: false) if @unchecked_ids.size > 0

    @additions = CartItem.checked_items(user_id: @user_id, buyer_id: params[:buyer_id], assistant: true)

    response.headers['X-Request-URL'] = request.url
  end

  def doc

  end

  def update
    @cart_item.update(quantity: params[:quantity])
    @additions = CartItem.checked_items(user_id: @cart_item.user_id, buyer_id: @cart_item.buyer_id, assistant: true)
  end

  def destroy
    @cart_item = CartItem.find params[:id]
    @cart_item.destroy
    @additions = CartItem.checked_items(user_id: @cart_item.user_id, buyer_id: @cart_item.buyer_id, assistant: true)
  end

  private
  def set_cart_item
    @cart_item = CartItem.find(params[:id])
    if @cart_item.user_id
      @cart_items = CartItem.where(assistant: true, user_id: @cart_item.user_id)
    else
      @cart_items = CartItem.where(assistant: true, buyer_id: @cart_item.buyer_id)
    end
  end

  def cart_item_params
    params.require(:cart_item).permit(id: [],
                                      single_price: [],
                                      amount: [],
                                      total_price: [])
  end

  def current_cart
    if params[:good_type] && params[:good_id]
      good = params[:good_type].safe_constantize&.find_by(id: params[:good_id])
      if good.respond_to?(:user_id)
        @user = User.find good.user_id
        @buyer = @user.buyer
        @cart_items = CartItem.where(assistant: true, good_type: params[:good_type], good_id: params[:good_id], user_id: good.user_id)
        @cart_items.where(assistant: true)
      end
    elsif params[:user_id].present?
      @cart_items = CartItem.where(assistant: true, user_id: params[:user_id])
      @user = User.find params[:user_id]
      @buyer = @user.buyer
    elsif params[:buyer_id].present?
      @buyer = Buyer.find params[:buyer_id]
      @cart_items = CartItem.where(assistant: true, buyer_id: params[:buyer_id])
    else
      @cart_items = CartItem.limit(0)
    end
    @cart_items = @cart_items.init
  end


end
