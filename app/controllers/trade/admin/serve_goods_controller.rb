class Trade::Admin::ServeGoodsController < Trade::Admin::BaseController
  before_action :set_serve_good, only: [:show, :edit, :update, :destroy]

  def index
    q_params = {}
    q_params.merge! params.permit(:serve_id, :good_type, :good_id)
    @serve_goods = ServeGood.default_where(q_params).page(params[:page])
    if params[:serve_id]
      @serve = Serve.find params[:serve_id]
    end
  end

  def goods
    # todo support search
    @goods = params[:good_type].constantize.order(id: :desc)
    @serve_good = ServeGood.new
    respond_to do |format|
      format.json { render json: { results: @goods } }
      format.js
    end
  end

  def show
  end

  def new
    @serve_good = ServeGood.new(params.permit(:serve_id, :good_type, :good_id))
  end

  def edit
  end

  def create
    @serve_good = ServeGood.new(serve_good_params)

    if @serve_good.save
      redirect_to admin_serve_goods_url(serve_id: @serve_good.serve_id)
    else
      render :new
    end
  end

  def update
    if @serve_good.update(serve_good_params)
      redirect_to admin_serve_goods_url(serve_id: @serve_good.serve_id)
    else
      render :edit
    end
  end

  def destroy
    @serve_good.destroy
    redirect_to admin_serve_goods_url(serve_id: @serve_good.serve_id)
  end

  private
  def set_serve_good
    @serve_good = ServeGood.find(params[:id])
  end

  def serve_good_params
    params.fetch(:serve_good, {}).permit(
      :serve_id,
      :good_type,
      :good_id,
      :available
    )
  end

end
