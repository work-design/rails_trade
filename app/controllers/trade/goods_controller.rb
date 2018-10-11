class Trade::GoodsController < ApplicationController
  before_action :set_good, only: [:show, :produce]

  def index
    @goods = Good.page(params[:page]).per(params[:per])
    @menus = List.kind_menus.joins(:items).where(items: {node_type: Item.node_types[:node_top]})

    respond_to do |format|
      format.html
      format.html.phone
      format.json { render json: @goods }
    end
  end

  def item
    @item = Item.includes(:goods).find params[:id]
    @menus = List.joins(:items).where(items: {node_type: Item.node_types[:node_top]})

    respond_to do |format|
      format.html
      format.json { render json: @item }
    end
  end

  def taxon
    @taxon = Item.find params[:id]
    @items = @taxon.children
    @goods = Good.joins(:good_items).where('good_items.item_id' => @items)

    if params[:area_id].to_i > 0
      @area = Area.find params[:area_id]
      @goods = @goods.where(:provider_id => @area.providers)
    end

    if params[:provider_id].to_i > 0
      @provider = Provider.find params[:provider_id]
      @goods = @goods.where(:provider_id => params[:provider_id])
    end

    @goods = @goods.page(params[:page])
    @goods = @goods.order("price #{params[:price_order]}") unless params[:price_order].nil?

    respond_to do |format|
      format.html
      format.json { render json: @goods }
    end
  end

  def market
    @market = Market.find(params[:id])

    # 相关产品
    needs = @market.needs.map { |i| i.id }
    items = ItemNeed.select(:item_id).where(:need_id => needs).map { |i| i.item_id }
    items.uniq!

    groups = GoodItem.where(:item_id => items).map { |i| i.good_id }
    a1 = groups.group_by { |i| i }
    a2 = a1.sort_by { |k, v| v.count }
    a3 = a2.reverse.map { |i|  i[0] }

    @groups = Good.find a3.slice(0..9)
    @items = Item.find items

  end

  def show

  end

  def produce
    @produces = @good.good_produces
  end

  def wiki
    @post = @good.producer.posts.where(:channel_id => Setting.wiki_channel).first
  end

  def buy
    redirect_to @good.buy_link
  end

  private
  def set_good
    @good = Good.find params[:id]
  end

end


