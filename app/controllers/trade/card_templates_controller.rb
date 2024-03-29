module Trade
  class CardTemplatesController < BaseController
    before_action :set_card_template, only: [:show]

    def index
      q_params = {}
      q_params.merge! default_params

      @card_templates = CardTemplate.default_where(q_params).page(params[:page])
    end

    def show
    end

    private
    def set_card_template
      @card_template = CardTemplate.find(params[:id])
    end

  end
end
