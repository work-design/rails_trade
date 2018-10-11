class Trade::AreasController < ApplicationController

  def search

    if params[:nation]
      @areas = Area.where(nation: params[:nation]).select(:province).distinct
      results = @areas.map { |x| { value: x.province, text: x.province, name: x.province } }
    elsif params[:province]
      @areas = Area.where(province: params[:province]).select(:city, :id).distinct
      results = @areas.map { |x| { value: x.id, text: x.city, name: x.city } }
    else
      results = []
    end

    render json: { values: results }
  end

end
