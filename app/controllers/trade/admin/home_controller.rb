module Trade
  class Admin::HomeController < Admin::BaseController

    def index
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

  end
end
