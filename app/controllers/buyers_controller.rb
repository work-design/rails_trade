class BuyersController < ApplicationController
  before_action :set_buyer, only: [:show, :edit, :update, :destroy]

  def index
    @buyers = Buyer.all
  end

  def search
    @buyers = Buyer.default_where('name-like': params[:q])
    render json: { results: @buyers.as_json(only: [:id, :name]) }
  end

  def show
  end

  def new
    @buyer = Buyer.new
  end

  def edit
  end

  def create
    @buyer = Buyer.new(buyer_params)

    if @buyer.save
      redirect_to @buyer, notice: 'Buyer was successfully created.'
    else
      render :new
    end
  end

  def update
    if @buyer.update(buyer_params)
      redirect_to @buyer, notice: 'Buyer was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @buyer.destroy
    redirect_to buyers_url, notice: 'Buyer was successfully destroyed.'
  end

  private
  def set_buyer
    @buyer = Buyer.find(params[:id])
  end

  def buyer_params
    params.fetch(:buyer, {})
  end

end
