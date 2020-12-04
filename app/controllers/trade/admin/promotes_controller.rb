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

    if @promote.save
      @promote_charge = @promote.promote_charges.build
    else
      render :new, locals: { model: @promote }, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @promote.assign_attributes promote_params

    unless @promote.save
      render :edit, locals: { model: @promote }, status: :unprocessable_entity
    end
  end

  def destroy
    @promote.destroy
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
      :editable,
      extra: []
    )
    p.merge! default_form_params
  end
end
