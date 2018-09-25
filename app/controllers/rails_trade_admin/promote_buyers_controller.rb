class RailsTradeAdmin::PromoteBuyersController < RailsTradeAdmin::BaseController
  before_action :set_promote_buyer, only: [:show, :edit, :update, :destroy]

  def index
    @promote_buyers = PromoteBuyer.includes(:buyer, :promote).default_where(params.permit(:buyer_id)).page(params[:page])
  end

  def show
  end

  def new
    @promote_buyer = PromoteBuyer.new(buyer_id: params[:buyer_id], promote_id: params[:promote_id])
  end

  def create
    @promote_buyer = PromoteBuyer.new(promote_buyer_params)

    if @promote_buyer.save
      redirect_to admin_promote_buyers_url(buyer_id: @promote_buyer.buyer_id), notice: 'Promote buyer was successfully created.'
    else
      render :new
    end
  end

  def destroy
    @promote_buyer.destroy
    redirect_to admin_promote_buyers_url(buyer_id: @promote_buyer.buyer_id), notice: 'Promote buyer was successfully destroyed.'
  end

  private
  def set_promote_buyer
    @promote_buyer = PromoteBuyer.find(params[:id])
  end

  def promote_buyer_params
    params.fetch(:promote_buyer, {}).permit(
      :buyer_id,
      :promote_id
    )
  end

end
