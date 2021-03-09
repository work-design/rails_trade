module Trade
  class My::CardLogsController < My::BaseController
    before_action :set_card

    def index
      @card_logs = @card.card_logs.page(params[:page])
    end

    private
    def set_card
      @card = Card.find params[:card_id]
    end

  end
end
