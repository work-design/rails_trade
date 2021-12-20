module Trade
  class Admin::CardTemplatesController < Admin::BaseController
    before_action :set_card_template, only: [:show, :advance_options, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:name)

      @card_templates = CardTemplate.default_where(q_params).order(id: :asc).page(params[:page])
    end

    def new
      @card_template = CardTemplate.new
      @card_template.advances.build
    end

    def advance_options
      @advances = @card_template.advances
    end

    private
    def set_card_template
      @card_template = CardTemplate.find(params[:id])
    end

    def card_template_params
      p = params.fetch(:card_template, {}).permit(
        :name,
        :description,
        :valid_years,
        :valid_months,
        :valid_days,
        :cover,
        :logo,
        :default,
        :text_color,
        :currency,
        :code,
        advances_attributes: {}
      )
      p.merge! default_form_params
    end

  end
end
