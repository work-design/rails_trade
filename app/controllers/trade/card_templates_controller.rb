module Trade
  class CardTemplatesController < BaseController
    before_action :set_card_template, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! default_params

      @card_templates = CardTemplate.default_where(q_params).page(params[:page])
    end

    def new
      @card_template = CardTemplate.new
    end

    def create
      @card_template = CardTemplate.new(card_template_params)

      if @card_template.save
        render 'create', locals: { return_to: card_card_templates_url }
      else
        render :new, locals: { model: @card_template }, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      @card_template.assign_attributes(card_template_params)

      if @card_template.save
        render 'update', locals: { return_to: card_card_templates_url }
      else
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
      params.fetch(:card_template, {}).permit(
        :name,
        :valid_days,
        :amount,
        :price
      )
    end

  end
end
