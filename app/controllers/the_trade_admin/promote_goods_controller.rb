class TheTradeAdmin::PromoteGoodsController < TheTradeAdmin::BaseController
  before_action :set_promote_good, only: [:show, :edit, :update, :destroy]

  def index
    @promote_goods = PromoteGood.page(params[:page])
  end

  def show
  end

  def new
    @promote_good = PromoteGood.new
  end

  def edit
  end

  def create
    @promote_good = PromoteGood.new(promote_good_params)

    if @promote_good.save
      redirect_to @promote_good, notice: 'Promote good was successfully created.'
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
    redirect_to promote_goods_url, notice: 'Promote good was successfully destroyed.'
  end

  private
  def set_promote_good
    @promote_good = PromoteGood.find(params[:id])
  end

  def promote_good_params
    params.fetch(:promote_good, {}).permit()
  end

end
