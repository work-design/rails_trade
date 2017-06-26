class Admin::ChargesController < Admin::TheTradeController
  before_action :set_charge, only: [:edit, :update, :destroy]

  def index
    @charges = Charge.default_where(unit: params[:unit], type: params[:type], 'min-gte': params[:min], 'max-lte': params[:max])
    @charges = @charges.order(unit: :asc, min: :asc).page(params[:page]).per(20)
  end

  def new
    @charge = Charge.new
  end

  def create
    @charge = Charge.new(charge_params)
    respond_to do |format|
      if @charge.save
        format.html { redirect_to admin_charges_url, notice: 'Charge was successfully created.' }
        format.js
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
        format.html { redirect_to admin_charges_url, notice: 'Charge was successfully updated.' }
        format.js
      else
        format.html { render :edit }
        format.js
      end
    end
  end

  def destroy
    if @charge.destroy
      redirect_to work_charges_url
    end
  end

  private

  def charge_params
    params.fetch(:charge, {}).permit(:unit, :min, :max, :price, :type)
  end

  def set_charge
    @charge = Charge.find params[:id]
  end

end
