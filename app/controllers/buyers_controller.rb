class BuyersController < ApplicationController

  def search
    @buyers = TheTrade.buyer_class.default_where('name-like': params[:q])
    render json: { results: @buyers.as_json(only: [:id], methods: [:name_detail]) }
  end

end
