module ControllerGood
  extend ActiveSupport::Concern
  
  included do
    before_action :set_goods, only: [:index]
    before_action :set_good, only: [:show, :edit, :update, :destroy]
  end

  def index
    @goods = Facilitate.page(params[:page])
  end

  def show
  end

  def new
    @good = Facilitate.new
    @options = FacilitateTaxon.select(:id, :name).all
  end

  def edit
    @options = FacilitateTaxon.select(:id, :name).all
  end

  def create
    @good = Facilitate.new(good_params)

    respond_to do |format|
      if @good.save
        @good.logo.attach(logo_params) if logo_params.present?
        format.html { redirect_to admin_goods_url, notice: 'Facilitate was successfully created.' }
        format.json { render :show, status: :created, location: @good }
      else
        format.html { render :new }
        format.json { render json: @good.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @good.logo.attach(logo_params) if logo_params.present?
    respond_to do |format|
      if @good.update(good_params)
        format.html { redirect_to admin_goods_url, notice: 'Facilitate was successfully updated.' }
        format.json { render :show, status: :ok, location: @good }
      else
        format.html { render :edit }
        format.json { render json: @good.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @good.destroy
    respond_to do |format|
      format.html { redirect_to admin_goods_url, notice: 'Facilitate was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # should overwrite
  def set_good
    @good = Facilitate.find(params[:id])
  end

  def good_params
    params.fetch(:good, {}).permit(:name, :desc, :good_taxon_id)
  end

  def logo_params
    params.fetch(:good, {}).permit(:logo).fetch(:logo, {})
  end

end
