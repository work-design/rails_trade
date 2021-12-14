module Trade
  class Admin::CardAdvancesController < Admin::BaseController
    before_action :set_card
    before_action :set_card_advance, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:advance_id)

      @card_advances = @card.card_advances.default_where(q_params).order(id: :desc).page(params[:page])
    end

    def new
      @card_advance = @card.card_advances.build
    end

    def create
      @card_advance = @card.card_advances.build(card_advance_params)

      unless @card_advance.save
        render :new, locals: { model: @card_advance }, status: :unprocessable_entity
      end
    end

    private
    def set_card
      @card = Card.find params[:card_id]
    end

    def set_card_advance
      @card_advance = CardAdvance.find(params[:id])
    end

    def card_advance_params
      params.fetch(:card_advance, {}).permit(
        :amount,
        :note
      )
    end

  end
end
