class Trade::Admin::PromoteChargesController < Trade::Admin::BaseController
  before_action :set_promote, except: [:options]
  before_action :set_charge, only: [:edit, :update, :destroy]

  def index
    q_params = {}
    q_params.merge! params.permit(PromoteCharge.extra_columns)
    q_params.merge! 'filter_min-lte': params[:value], 'filter_max-gte': params[:value]

    @promote_charges = @promote.promote_charges.default_where(q_params).order(min: :asc).page(params[:page]).per(params[:per])
  end

  def options

  end

  def new
    @promote_charge = @promote.promote_charges.build
  end

  def create
    @promote_charge = @promote.promote_charges.build(promote_charge_params)

    unless @promote_charge.save
      render :new, locals: { model: @promote_charge }, status: :unprocessable_entity
    end
  end

  def edit

  end

  def update
    @promote_charge.assign_attributes(promote_charge_params)

    unless @promote_charge.save
      render :edit, locals: { model: @promote_charge }, status: :unprocessable_entity
    end
  end

  def destroy
    @promote_charge.destroy
  end

  private
  def promote_charge_params
    params.fetch(:promote_charge, {}).permit(
      :min,
      :max,
      :type,
      :unit,
      :parameter,
      :contain_min,
      :contain_max,
      *PromoteCharge.extra_columns
    )
  end

  def set_promote
    @promote = Promote.find params[:promote_id]
  end

  def set_charge
    @promote_charge = PromoteCharge.find params[:id]
  end

end
