class Admin::GoodsController < Admin::BaseController
  before_action :set_good, :only => [:edit, :update, :edit_pic, :update_pic, :edit_items, :update_items, :edit_promote, :update_promote, :edit_taxons, :update_taxons, :destroy]

  def index
    @goods = Good.page(params[:page])
  end

  def new
    @good = Good.new
  end

  def create
    @good = Good.new good_params

    if @good.save
       redirect_to admin_goods_url, notice: '产品添加成功'
    else
      render action: "new", :notice => '添加失败'
    end
  end

  def edit
    @good = Good.find(params[:id])
    @provider = @good.provider
  end

  def update
    @good = Good.find(params[:id])

    if @good.update(good_params)
      redirect_to admin_goods_url, notice: 'Good was successfully updated.'
    else
      render action: "edit"
    end
  end

  def edit_items
    @items = Item.all
  end

  def update_items
    if @good.update(items_params)
      redirect_to admin_good_url(@good), notice: '更新成功'
    else
      render action: "edit_items"
    end
  end

  def edit_promote

  end

  def update_promote

    if @good.update_attributes(promote_params)
      redirect_to good_url(@good), notice: '更新成功'
    else
      render action: "edit_promote"
    end
  end

  def edit_pic
    @photo = Photo.new
  end

  def update_pic
    @photo = @good.photos.build photo_params
    @photo.save

    redirect_to pic_good_url(params[:id])
  end

  def destroy
    @good = Good.find(params[:id])
    @good.destroy

    redirect_to goods_url
  end

  private
  def set_good
    @good = Good.find params[:id]
  end

  def good_params
    params[:good].permit(:name,  :provider_id, :logo, :logo_cache, :title, :title_abbr, :sku, :position, :price, :price_lower, :buy_link, :overview)
  end

  def photo_params
    params[:photo].permit(:photo, :photo_cache, :title, :description)
  end

  def items_params
    params[:good].permit(:item_ids => [])
  end

  def promote_params
    params[:good].permit(:promote_id, :start_at, :finish_at)
  end

end
