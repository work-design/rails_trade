module ControllerGoodProvider
  extend ActiveSupport::Concern

  included do
    before_action :set_good, only: [:index]
    before_action :set_good_provider, only: [:show, :edit, :verify, :select, :update, :destroy]
  end
  
  def index
    @good_providers = @good.good_providers.order(id: :asc).page(params[:page])
  end

  def show
  end

  def new
    @good_provider = @good.good_providers.build
  end

  def edit
  end

  def verify
    if params[:verified] == '1'
      @good_provider.update(verified: true)
    else
      @good_provider.update(verified: false)
    end
  end

  def select
    @good_provider.set_selected
    redirect_to admin_good_good_providers_url(@good_provider.good_id)
  end

  def create
    @good_provider = @good.good_providers.build(good_provider_params)

    respond_to do |format|
      if @good_provider.save
        format.html { redirect_to @good_provider, notice: 'Facilitate provider was successfully created.' }
        format.json { render :show, status: :created, location: @good_provider }
      else
        format.html { render :new }
        format.json { render json: @good_provider.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @good_provider.update(good_provider_params)
        format.html { redirect_to @good_provider, notice: 'Facilitate provider was successfully updated.' }
        format.json { render :show, status: :ok, location: @good_provider }
      else
        format.html { render :edit }
        format.json { render json: @good_provider.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @good_provider.destroy
    respond_to do |format|
      format.html { redirect_to good_providers_url, notice: 'Facilitate provider was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  def set_good
    @good = Facilitate.find params[:good_id]
  end

  def set_good_provider
    @good_provider = FacilitateProvider.find(params[:id])
  end

  def good_provider_params
    params.fetch(:good_provider, {})
  end
end
