module Trade
  class In::CardTemplatesController < Admin::CardTemplatesController
    before_action :set_card_template, only: [:show]

    def show
      @card = current_client.cards.formal.find_by(card_template_id: @card_template.id)
    end

  end
end
