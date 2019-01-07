class Trade::Admin::PromoteGoodsController < Trade::Admin::BaseController
  before_action :set_promote_good, only: [:show, :edit, :update, :destroy]

  def index
    q_params = {}.with_indifferent_access
    q_params.merge! params.permit(:promote_id, :good_type, :good_id)
    @promote_goods = PromoteGood.default_where(q_params).page(params[:page])
    if params[:promote_id]
      @promote = Promote.find params[:promote_id]
    end
  end

  def goods
    @goods = params[:good_type].constantize.page(params[:page])
    @promote_good = PromoteGood.new
    respond_to do |format|
      format.json { render json: { results: @goods } }
      format.js
    end
  end

  def show
  end

  def new
    @promote_good = PromoteGood.new(params.permit(:promote_id, :good_type, :good_id))
  end

  def edit
  end

  def create
    @promote_good = PromoteGood.new(promote_good_params)

    if @promote_good.save
      redirect_to admin_promote_goods_url(promote_id: @promote_good.promote_id), notice: 'Promote good was successfully created.'
    else
      render :new
    end
  end

  def update
    if @promote_good.update(promote_good_params)
      redirect_to @promote_good, notice: 'Promote good was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @promote_good.destroy
    redirect_to admin_promote_goods_url(promote_id: @promote_good.promote_id), notice: 'Promote good was successfully destroyed.'
  end

  private
  def set_promote_good
    @promote_good = PromoteGood.find(params[:id])
  end

  def promote_good_params
    params.fetch(:promote_good, {}).permit(
      :promote_id,
      :good_type,
      :good_id
    )
  end

end
