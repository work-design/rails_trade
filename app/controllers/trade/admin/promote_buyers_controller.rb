class Trade::Admin::PromoteBuyersController < Trade::Admin::BaseController
  before_action :set_promote_buyer, only: [:show, :destroy]

  def index
    q_params = {}.with_indifferent_access
    q_params.merge! params.permit(:promote_id, :buyer_type, :buyer_id)
    @promote_buyers = PromoteBuyer.includes(:buyer, :promote).default_where(q_params).page(params[:page])
    if params[:promote_id]
      @promote = Promote.find params[:promote_id]
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
      redirect_to admin_promote_buyers_url(buyer_id: @promote_buyer.buyer_id)
    else
      render :new
    end
  end

  def destroy
    @promote_buyer.destroy
    redirect_to admin_promote_buyers_url(buyer_id: @promote_buyer.buyer_id)
  end

  private
  def set_promote_buyer
    @promote_buyer = PromoteBuyer.find(params[:id])
  end

  def promote_buyer_params
    q = params.fetch(:promote_buyer, {}).permit(
      :buyer_type,
      :buyer_id,
      :promote_id
    )
    q[:buyer_type] = 'User' if q[:buyer_type].blank?
    q
  end

end
