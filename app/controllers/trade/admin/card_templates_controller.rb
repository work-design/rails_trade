module Trade
  class Admin::CardTemplatesController < Admin::BaseController
    before_action :set_card_template, only: [:show, :advance_options, :edit, :update, :destroy]
    before_action :set_new_card_template, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:name)

      @card_templates = CardTemplate.default_where(q_params).order(id: :asc).page(params[:page])
    end

    def new
    end

    def advance_options
      @advances = @card_template.advances
    end

    private
    def set_card_template
      @card_template = CardTemplate.find(params[:id])
    end

    def set_new_card_template
      @card_template = CardTemplate.new(card_template_params)
    end

    def card_template_params
      p = params.fetch(:card_template, {}).permit(
        :name,
        :description,
        :cover,
        :logo,
        :grade,
        :text_color,
        :currency,
        :code,
        advances_attributes: {}
      )
      p.merge! default_form_params
    end

  end
end
