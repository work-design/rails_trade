module Trade
  class Admin::CardPurchasesController < Admin::BaseController
    before_action :set_card
    before_action :set_card_purchase, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:purchase_id)

      @card_purchases = @card.card_purchases.default_where(q_params).order(id: :desc).page(params[:page])
    end

    def new
      @card_purchase = @card.card_purchases.build
    end

    def create
      @card_purchase = @card.card_purchases.build(card_purchase_params)

      unless @card_purchase.save
        render :new, locals: { model: @card_purchase }, status: :unprocessable_entity
      end
    end

    private
    def set_card
      @card = Card.find params[:card_id]
    end

    def set_card_purchase
      @card_purchase = CardPurchase.find(params[:id])
    end

    def card_purchase_params
      params.fetch(:card_purchase, {}).permit(
        :amount,
        :note
      )
    end

  end
end
