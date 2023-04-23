module Trade
  class Admin::CardsController < Admin::BaseController
    before_action :set_card_templates, only: [:index]
    before_action :set_card_template
    before_action :set_new_card, only: [:new, :create]
    before_action :set_card, only: [:show, :edit, :update, :destroy, :actions]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:id, :card_uuid)

      @cards = @card_template.cards.default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_card
      @card = @card_template.cards.find(params[:id])
    end

    def set_new_card
      @card = @card_template.cards.build(card_params)
    end

    def set_card_template
      @card_template = CardTemplate.find params[:card_template_id]
    end

    def set_card_templates
      @card_templates = CardTemplate.default_where(default_params)
    end

    def card_params
      params.fetch(:card, {}).permit(
        :type,
        :card_uuid,
        :effect_at,
        :expire_at,
        :amount,
        :income_amount
      )
    end

  end
end
