module Trade
  class Our::CardTemplatesController < My::CardTemplatesController
    before_action :set_card_template, only: [:show]

    def show
      @card = current_client.cards.formal.find_by(card_template_id: @card_template.id)
    end

    private

  end
end
