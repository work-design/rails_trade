class TheTradeAdmin::GoodServesController < TheTradeAdmin::BaseController
  before_action :set_good

  def index
    @good_serves = GoodServe.includes(:serve).where(good_type: params[:good_type], good_id: params[:good_id])
  end

  def show
  end

  def new
    @good_serve = @good.good_serves.find_or_initialize_by(serve_id: params[:serve_id])
    @serve_charge = @good.serve.get_charge_by_serve_id(@good_serve.serve_id)
  end

  def create
    @good_serve = @good.good_serves.find_or_initialize_by(serve_id: good_serve_params[:serve_id])
    @good_serve.assign_attributes good_serve_params

    respond_to do |format|
      if @good_serve.save
        format.js
        format.html { redirect_to @good_serve, notice: 'Taxon item was successfully created.' }
      else
        format.js
        format.html { render :new }
      end
    end
  end

  def destroy
    @good_serve.destroy
  end

  private
  def set_good
    @good = params[:good_type].safe_constantize.find params[:good_id]
  end

  def good_serve_params
    params.fetch(:good_serve, {}).permit(:serve_id, :price)
  end

end
