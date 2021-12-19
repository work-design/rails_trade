module Trade
  class My::CardPurchasesController < My::BaseController
    before_action :set_card

    def index
      @card_purchases = @card.card_purchases.order(last_expire_on: :desc).page(params[:page])
    end

    private
    def set_card
      @card = Card.find params[:card_id]
    end

  end
end
