class TheTradeMy::CartItemsController < TheTradeMy::BaseController
  before_action :current_cart, only: [:index, :total]
  before_action :set_cart_item, only: [:update, :destroy]

  def index
    @checked_ids = @cart_items.checked.pluck(:id)
    @additions = AdditionService.new(@checked_ids)
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

    @checked_ids = @cart_items.checked.pluck(:id)
    @ps = PromoteService.new(@checked_ids)

    render 'index'
  end

  def total
    checked_ids = params[:cart_item_ids].to_s.split(',').map { |id| id.to_i }

    if checked_ids.size == 0
      @cart_items.update_all(checked: false)
    elsif checked_ids.size > 0
      CartItem.where(id: checked_ids).update_all(checked: true)
      unchecked_ids = @cart_items.pluck(:id) - checked_ids
      CartItem.where(id: unchecked_ids).update_all(checked: false) if unchecked_ids.size > 0
    end
    @ps = PromoteService.new(checked_ids)
  end

  def update
    @cart_item.update(quantity: params[:quantity])
    checked_ids = @cart_items.checked.pluck(:id)
    @ps = PromoteService.new(checked_ids)
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
