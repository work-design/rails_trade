module Trade
  class My::CardPurchasesController < My::BaseController
    before_action :set_card

    def index
      @card_purchases = @card.card_purchases.where.not(last_expire_at: nil).order(last_expire_at: :desc).page(params[:page])
    end

    private
    def set_card
      @card = Card.find params[:card_id]
    end

  end
end
