class Trade::Admin::PromoteChargesController < Trade::Admin::BaseController
  before_action :set_promote
  before_action :set_charge, only: [:edit, :update, :destroy]

  def index
    q_params = {}
    q_params.merge! params.permit(PromoteCharge.extra_columns)
    q_params.merge! 'filter_min-lte': params[:value], 'filter_max-gte': params[:value]
    
    @promote_charges = @promote.promote_charges.default_where(q_params).order(min: :asc).page(params[:page]).per(params[:per])
  end

  def new
    @promote_charge = @promote.promote_charges.build
  end

  def create
    @promote_charge = @promote.promote_charges.build(promote_charge_params)
    
    respond_to do |format|
      if @promote_charge.save
        format.html { redirect_to admin_promote_charges_url(@promote) }
        format.js { redirect_to admin_promote_charges_url(@promote) }
      else
        format.html { render :new }
        format.js
      end
    end
  end

  def edit

  end

  def update
    respond_to do |format|
      if @promote_charge.update(promote_charge_params)
        format.html { redirect_to admin_promote_charges_url(@promote) }
        format.js { redirect_to admin_promote_charges_url(@promote) }
      else
        format.html { render :edit }
        format.js
      end
    end
  end

  def destroy
    if @promote_charge.destroy
      redirect_to admin_promote_charges_url(@promote)
    end
  end

  private
  def promote_charge_params
    params.fetch(:promote_charge, {}).permit(
      :min,
      :max,
      :type,
      :metering,
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
