module Trade
  class My::CardsController < My::BaseController
    before_action :set_card, only: [:show, :edit, :update, :destroy]
    before_action :set_card_templates, only: [:show]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:card_uuid, :card_template_id)

      @cards = current_cart.cards.includes(:card_template).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def new
      @card = current_cart.cards.find_or_initialize_by(card_template_id: params[:card_template_id])
    end

    def token
      @card_prepayment = CardPrepayment.find_by token: params[:token]
      @card = current_user.cards.find_or_initialize_by(card_template_id: @card_prepayment.card_template_id)
      @card.card_advances.build(amount: @card_prepayment.amount)
    end

    def create
      if token_params[:token]
        @card_prepayment = CardPrepayment.find_by token: token_params[:token]
        @card = current_cart.cards.find_or_initialize_by(card_template_id: @card_prepayment.card_template_id)
      else
        @card = current_user.cards.build(card_params)
      end
      @card.assign_attributes card_params

      unless @card.save
        render :new, locals: { model: @card }, status: :unprocessable_entity
      end
    end

    private
    def set_card_templates
      q_params = {
        grade: 1
      }
      q_params.merge! default_params

      # @card_templates = CardTemplate.default_where(q_params).where.not(id: @cards.pluck(:card_template_id))
      @card_templates = CardTemplate.default_where(default_params)
    end

    def set_card
      @card = Card.default_where(default_params).find(params[:id])
    end

    def token_params
      params.fetch(:card, {}).permit(:token)
    end

    def card_params
      params.fetch(:card, {}).permit(
        :type,
        :card_uuid,
        :effect_at,
        :expire_at,
        :amount,
        :income_amount,
        card_advances_attributes: [:amount]
      )
    end

  end
end
