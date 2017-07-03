class BuyersController < ApplicationController

  def search
    @buyers = Company.default_where('name-like': params[:q])
    render json: { results: @buyers.as_json(only: [:id, :name]) }
  end

end
