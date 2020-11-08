class Trade::Admin::PromoteBuyersController < Trade::Admin::BaseController
  before_action :set_promote_buyer, only: [:show, :destroy]

  def index
    q_params = {}
    q_params.merge! params.permit(:promote_id, :buyer_type, :buyer_id)
    @promote_buyers = PromoteCart.includes(:buyer, :promote).default_where(q_params).page(params[:page])
    if params[:promote_good_id]
      @promote_good = PromoteGood.find params[:promote_good_id]
    end
  end

  def show
  end

  def new
    @promote_buyer = PromoteBuyer.new(
      buyer_type: params[:buyer_type],
      buyer_id: params[:buyer_id],
      promote_id: params[:promote_id],
    )
  end

  def create
    @promote_buyer = PromoteBuyer.new(promote_buyer_params)

    if @promote_buyer.save
      render 'create'
    else
      render :new, locals: { model: @promote_buyer }, status: :unprocessable_entity
    end
  end

  def destroy
    @promote_buyer.destroy
  end

  private
  def set_promote_buyer
    @promote_buyer = PromoteBuyer.find(params[:id])
  end

  def promote_buyer_params
    q = params.fetch(:promote_buyer, {}).permit(
      :buyer_type,
      :buyer_id,
      :promote_good_id,
      :status,
      :effect_at,
      :expire_at
    )
    q[:buyer_type] = 'User' if q[:buyer_type].blank?
    q
  end

end
