class Trade::Admin::PromoteCartsController < Trade::Admin::BaseController
  before_action :set_promote_cart, only: [:show, :destroy]

  def index
    q_params = {}
    q_params.merge! params.permit(:promote_id, :buyer_type, :buyer_id)
    @promote_carts = PromoteCart.includes(:buyer, :promote).default_where(q_params).page(params[:page])
    if params[:promote_good_id]
      @promote_good = PromoteGood.find params[:promote_good_id]
    end
  end

  def show
  end

  def new
    @promote_cart = PromoteCart.new(
      promote_id: params[:promote_id],
    )
  end

  def create
    @promote_cart = PromoteCart.new(promote_cart_params)

    if @promote_cart.save
      render 'create'
    else
      render :new, locals: { model: @promote_cart }, status: :unprocessable_entity
    end
  end

  def destroy
    @promote_cart.destroy
  end

  private
  def set_promote_cart
    @promote_cart = PromoteCart.find(params[:id])
  end

  def promote_cart_params
    params.fetch(:promote_cart, {}).permit(
      :cart_id,
      :promote_good_id,
      :status,
      :effect_at,
      :expire_at
    )
  end

end
