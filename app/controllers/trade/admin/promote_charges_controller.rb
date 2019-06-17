class Trade::Admin::PromoteChargesController < Trade::Admin::BaseController
  before_action :set_promote
  before_action :set_charge, only: [:edit, :update, :destroy]

  def index
    q_params = {}
    q_params.merge! params.permit(@promote.extra)
    q_params.merge! 'min-lte': params[:value], 'max-gte': params[:value]
  
  
    @promote_charges = @promote.promote_charges.default_where(q_params).order(min: :asc).page(params[:page]).per(params[:per])
  end

  def new
    @charge = @promote.promote_charges.build
  end

  def create
    @charge = @promote.promote_charges.build(charge_params)
    
    respond_to do |format|
      if @charge.save
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
      if @charge.update(charge_params)
        format.html { redirect_to admin_promote_charges_url(@promote) }
        format.js { redirect_to admin_promote_charges_url(@promote) }
      else
        format.html { render :edit }
        format.js
      end
    end
  end

  def destroy
    if @charge.destroy
      redirect_to admin_promote_charges_url(@promote)
    end
  end

  private
  def charge_params
    attrs = [:min, :max, :parameter, :type] + @promote.extra
    params.fetch(:charge, {}).permit(attrs)
  end

  def set_promote
    @promote = Promote.find params[:promote_id]
  end

  def set_charge
    @promote_charge = PromoteCharge.find params[:id]
  end

end
