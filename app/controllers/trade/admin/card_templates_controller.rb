module Trade
  class Admin::CardTemplatesController < Admin::BaseController
    before_action :set_card_template, only: [:show, :advance_options, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:name)

      @card_templates = CardTemplate.default_where(q_params).page(params[:page])
    end

    def new
      @card_template = CardTemplate.new
      @card_template.advances.build
    end

    def create
      @card_template = CardTemplate.new(card_template_params)

      unless @card_template.save
        render :new, locals: { model: @card_template }, status: :unprocessable_entity
      end
    end

    def show
    end

    def advance_options
      @advances = @card_template.advances
    end

    def edit
    end

    def update
      @card_template.assign_attributes(card_template_params)

      unless @card_template.save
        render :edit, locals: { model: @card_template }, status: :unprocessable_entity
      end
    end

    def destroy
      @card_template.destroy
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
        :default,
        :currency,
        advances_attributes: {}
      )
      p.merge! default_form_params
    end

  end
end
