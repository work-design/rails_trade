class Trade::Admin::TradeItemsController < Trade::Admin::BaseController
  #before_action :set_cart_items, only: [:index, :create, :only, :total]
  before_action :set_cart_item, only: [:update, :destroy]
  skip_before_action :verify_authenticity_token, only: [:total]

  def index
    q_params = {}
    q_params.merge! params.permit(:trade_type, :trade_id, :good_type, :good_id, :address_id)

    #@checked_ids = @cart_items.checked.pluck(:id)
    @trade_items = TradeItem.default_where(q_params).page(params[:page]).per(params[:per])
  end

  def only
    unless params[:good_type] && params[:good_id]
      redirect_back(fallback_location: admin_cart_items_url) and return
    end

    good = params[:good_type].safe_constantize&.find_by(id: params[:good_id])
    if good.respond_to?(:user_id)
      @user = good.user
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

    response.headers['X-Request-URL'] = request.url
  end

  def doc

  end

  def update
    @cart_item.update(quantity: params[:quantity])
  end

  def destroy
    @cart_item.destroy
  end

  private
  def set_cart_item
    @cart_item = CartItem.find(params[:id])
    @cart_items = CartItem.where(buyer_type: @cart_item.buyer_type, buyer_id: @cart_item.buyer_id)
  end

  def set_additions
    if params[:buyer_type].present? && params[:buyer_id].present?
      @additions = CartItem.checked_items(buyer_type: params[:buyer_type], buyer_id: params[:buyer_id])
    elsif params[:id]
      @additions = CartItem.checked_items(buyer_type: @cart_item.buyer_type, buyer_id: @cart_item.buyer_id)
    else
      @additions = CartItem.checked_items(buyer_type: nil, buyer_id: nil)
    end
  end

  def set_cart_items
    if params[:buyer_type].present? && params[:buyer_id].present?
      @buyer = params[:buyer_type].constantize.find params[:buyer_id]
      @cart_items = CartItem.where(buyer_type: params[:buyer_type], buyer_id: params[:buyer_id])
    elsif params[:id].present?
      @cart_items = CartItem.where(id: params[:id])
    else
      @cart_items = CartItem.none
    end
    @cart_items = @cart_items.pending.default_where(params.permit(:good_type, :myself, :id))
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
