class TheTradeAdmin::GoodsController < TheTradeAdmin::BaseController
  before_action :set_good, only: [:show, :edit, :update, :destroy]

  def index
    @goods = Good.page(params[:page])
  end

  def new
    @good = Good.new(sku: params[:sku])
  end

  def create
    @good = Good.new good_params

    if @good.save
      render 'create', notice: '产品添加成功'
    else
      render action: 'new', notice: '添加失败'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @good.update(good_params)
      redirect_to admin_goods_url, notice: 'Good was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @good.destroy
    redirect_to admin_goods_url
  end

  private
  def set_good
    @good = Good.find params[:id]
  end

  def good_params
    params[:good].permit(:name, :sku, :unit, :price, :price_lower)
  end

  def promote_params
    params[:good].permit(:promote_id, :start_at, :finish_at)
  end

end
