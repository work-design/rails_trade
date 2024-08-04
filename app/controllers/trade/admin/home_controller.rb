module Trade
  class Admin::HomeController < Admin::BaseController

    def index
      @orders_count = Order.default_where(default_params).count
      @items_count = Item.default_where(default_params).count
    end

    def good_search
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit('name-like')

      if params[:good_type] == 'Bench::Facilitate'
      else
        @goods = Factory::Production.default_where(q_params)
      end
    end

    def part_search
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit('name-like')

      if params[:good_type] == 'Bench::Facilitate'
      else
        @goods = Factory::Production.default_where(q_params)
      end
    end

  end
end
