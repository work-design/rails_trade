class Trade::Admin::PromotesController < Trade::Admin::BaseController
  before_action :set_promote, only: [:show, :edit, :update, :destroy]

  def index
    q_params = {}
    q_params.merge! default_params
    q_params.merge! params.permit(:scope)
    
    @promotes = Promote.default_where(q_params).order(id: :desc).page(params[:page])
  end

  def search
    @promotes = Promote.default_where('name-like': params[:q])
    render json: { results: @promotes.as_json(only: [:id, :name]) }
  end

  def new
    @promote = Promote.new
  end

  def create
    @promote = Promote.new(promote_params)
    
    respond_to do |format|
      if @promote.save
        format.html { redirect_to admin_promotes_url }
        format.json { render action: 'show', status: :created, location: @promote }
      else
        format.html { render action: 'new' }
        format.json { render json: @promote.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    @promote.assign_attributes promote_params

    respond_to do |format|
      if @promote.save
        format.html { redirect_to admin_promotes_url }
        format.json { head :no_content }
        format.js { redirect_to admin_promotes_url }
      else
        format.html { render action: 'edit' }
        format.json { render json: @promote.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy
    @promote.destroy
    respond_to do |format|
      format.html { redirect_to admin_promotes_url }
      format.json { head :no_content }
    end
  end

  private
  def set_promote
    @promote = Promote.find(params[:id])
  end

  def promote_params
    p = params.fetch(:promote, {}).permit(
      :name,
      :code,
      :short_name,
      :description,
      :scope,
      :metering,
      :effect_at,
      :expire_at,
      :editable,
      extra: []
    )
    p.merge! default_params
  end
end
