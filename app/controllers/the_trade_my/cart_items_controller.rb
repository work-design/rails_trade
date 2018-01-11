class TheTradeMy::CartItemsController < TheTradeMy::BaseController
  before_action :current_cart, only: [:index, :total]
  before_action :set_cart_item, only: [:update, :destroy]

  def index
    @checked_ids = @cart_items.checked.pluck(:id)
    @additions = CartItem.checked_items(user_id: current_user&.id, session_id: session.id, assistant: false)
  end

  def create
    cart_item = current_cart.where(good_id: params[:good_id], good_type: params[:good_type]).first
    params[:quantity] ||= 1
    if cart_item.present?
      cart_item.quantity = cart_item.quantity + params[:quantity].to_i
      cart_item.assistant = false
      cart_item.save
    else
      cart_item = current_cart.build(good_id: params[:good_id], good_type: params[:good_type], quantity: params[:quantity], status: 'unpaid', assistant: false)
      cart_item.save
    end

    @checked_ids = @cart_items.checked.pluck(:id)
    @additions = CartItem.checked_items(user_id: current_user&.id, session_id: session.id, assistant: false)

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

    @additions = CartItem.checked_items(user_id: current_user&.id, session_id: session.id, assistant: false)
  end

  def update
    @cart_item.update(quantity: params[:quantity])
    @additions = CartItem.checked_items(user_id: current_user&.id, session_id: session.id, assistant: false)
  end

  def destroy
    @cart_item.update(status: :deleted, checked: false)
    @additions = CartItem.checked_items(user_id: current_user&.id, session_id: session.id, assistant: false)
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
    if current_user
      @cart_items = current_user.cart_items.valid
    else
      @cart_items = CartItem.where(session_id: session.id).valid
    end
  end


end
