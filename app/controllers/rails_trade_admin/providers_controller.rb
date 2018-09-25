class RailsTradeAdmin::ProvidersController < RailsTradeAdmin::BaseController
  before_action :set_provider, :only => [:show, :edit, :update, :type, :destroy, :products, :posts, :channel]

  def index
    @providers = Provider.page(params[:page])

    respond_to do |format|
      format.html { render }
      format.json { render json: @providers }
    end
  end

  def new
    @provider = Provider.new

    respond_to do |format|
      format.html
      format.json { render json: @provider }
    end
  end

  def create
    @provider = Provider.new(provider_params)

    respond_to do |format|
      if @provider.save
        format.html { redirect_to admin_providers_url, notice: 'Provider was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def area
    @providers = Provider.where(:area_id => params[:p])

    respond_to do |format|
      format.html { render :layout => false }
      format.js { render :layout => false }
      format.json { render json:@providers }
    end
  end

  def show

    respond_to do |format|
      format.html
      format.json { render json: @providers }
    end
  end

  def products
    @products = @provider.products.page(params[:page])
  end

  def posts
    @posts = @provider.posts
    @channels = Channel.where :wordage_type => 'Provider'

    respond_to do |format|
      format.html
      format.json
    end
  end

  def channel
    @channel = Channel.find params[:channel_id]
    @channels = Channel.where :wordage_type => 'Provider'
  end

  def edit
  end

  def update

    respond_to do |format|
      if @provider.update(provider_params)
        format.html { redirect_to admin_providers_url, notice: 'Provider was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end
  end

  def type
    respond_to do |format|
      if @provider.update(type_params)
        format.html { redirect_to @provider, notice: 'Provider was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "show" }
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @provider.destroy

    respond_to do |format|
      format.html { redirect_to providers_url }
      format.json { head :no_content }
    end
  end

  private
  def set_provider
    @provider = Provider.find params[:id]
  end

  def provider_params
    params[:provider].permit(
      :area_id,
      :name,
      :logo,
      :address,
      :service_tel,
      :service_qq
    )
  end

  def type_params
    params[:provider].permit(:type)
  end

end
