module Trade
  class ItemsController < BaseController

    def chart
    end

    def month
      q_params = {
        #good_type: ['Ship::BoxHost', 'Ship::BoxSell']
      }
      x = Arel.sql("date_trunc('month', created_at, '#{Time.zone.tzinfo.identifier}')")

      r =  Trade::Item.where(q_params).group(x).order(x).average(:single_price)

      result = []
      r.each do |key, v|
        result << { year: key.in_time_zone.to_fs(:month), value: v.round(2).to_f }
      end

      render json: result
    end

  end
end
