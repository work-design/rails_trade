module Trade
  class Admin::CardPurchasesController < Admin::BaseController
    before_action :set_card
    before_action :set_card_purchase, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_card_purchase, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! params.permit(:purchase_id)

      @card_purchases = @card.card_purchases.default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_card
      @card = Card.find params[:card_id]
    end

    def set_card_purchase
      @card_purchase = CardPurchase.find(params[:id])
    end

    def set_new_card_purchase
      @card_purchase = @card.card_purchases.build(card_purchase_params)
    end

    def card_purchase_params
      params.fetch(:card_purchase, {}).permit(
        :amount,
        :note
      )
    end

  end
end
