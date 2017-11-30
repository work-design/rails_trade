class TheTradeAdmin::AddressesController < TheTradeAdmin::BaseController
  before_action :set_addresses, only: [:index]
  before_action :set_address, only: [:show, :edit, :update, :destroy]

  def index
  end

  def new
    @address = Address.new(user_id: params[:user_id])
  end

  def create
    @address = Address.new(address_params)

    if @address.save
      redirect_to admin_addresses_url(user_id: @address.user_id), notice: 'Address was successfully created.'
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @address.update(address_params)
      redirect_to admin_addresses_url(user_id: @address.user_id), notice: 'Address was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @address.destroy
    redirect_to admin_addresses_url(user_id: @address.user_id), notice: 'Address was successfully destroyed.'
  end

  private
  def set_addresses
    if params[:user_id]
      @addresses = Address.includes(:area).where(user_id: params[:user_id])
    elsif params[:buyer_id]
      @addresses = Address.includes(:area).where(buyer_id: params[:buyer_id])
    else
      @addresses = Address.limit(0)
    end
  end

  def set_address
    @address = Address.find(params[:id])
  end

  def address_params
    params.fetch(:address, {}).permit(:user_id, :buyer_id, :area_id, :kind, :contact_person, :tel, :address)
  end

end
