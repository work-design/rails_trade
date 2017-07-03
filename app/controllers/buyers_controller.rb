class BuyersController < ApplicationController

  def search
    if params[:buyer_type] && params[:buyer_type].safe_constantize
      @buyers = params[:buyer_type].safe_constantize.default_where('name-like': params[:q])
      render json: { results: @buyers.as_json(only: [:id, :name]) }
    else
      render json: { results: [] }
    end
  end

end
