class TheTradeAdmin::ServesController < TheTradeAdmin::BaseController
  before_action :set_serve, only: [:show, :edit, :update, :toggle, :overall, :destroy]

  def index
    @serves = Serve.default_where(params.permit(:scope)).page(params[:page])
  end

  def search
    @serves = Serve.special.default_where('name-like': params[:q])
    render json: { results: @serves.as_json(only: [:id, :name]) }
  end

  def new
    @serve = Serve.new
  end

  def create
    @serve = Serve.new(serve_params)

    respond_to do |format|
      if @serve.save
        format.html { redirect_to admin_serves_url, notice: 'Serve was successfully created.' }
        format.json { render action: 'show', status: :created, location: @serve }
      else
        format.html { render action: 'new' }
        format.json { render json: @serve.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @serve.update(serve_params)
        format.html { redirect_to admin_serves_url, notice: 'Serve was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @serve.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle
    if params[:verified] == '1'
      @serve.update(verified: true)
    else
      @serve.update(verified: false)
    end

    head :no_content
  end

  def overall
    if params[:overall] == '1'
      @serve.update(overall: true)
    else
      @serve.update(overall: false)
    end

    head :no_content
  end

  def destroy
    @serve.destroy
    respond_to do |format|
      format.html { redirect_to admin_serves_url }
      format.json { head :no_content }
    end
  end

  private
  def set_serve
    @serve = Serve.find(params[:id])
  end

  def serve_params
    sp = params.fetch(:serve, {}).permit(:unit, :type, :name, :verified, :scope, extra: [])
    sp.fetch(:extra, []).reject! { |i| i.blank? }
    sp
  end
end
