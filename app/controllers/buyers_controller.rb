class BuyersController < ApplicationController

  def search
    if PaymentReference.options_i18n(:buyer_type).values.include?(params[:buyer_type].to_sym) && params[:buyer_type].safe_constantize
      @buyers = params[:buyer_type].safe_constantize.default_where('name-like': params[:q])
      render json: { results: @buyers.as_json(only: [:id], methods: [:name_detail]) }
    else
      render json: { results: [] }
    end
  end

end
