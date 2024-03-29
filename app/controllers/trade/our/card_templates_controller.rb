module Trade
  class Our::CardTemplatesController < My::CardTemplatesController
    include Controller::Our

    def index
      q_params = {}
      q_params.merge! default_params

      @card_templates = CardTemplate.default_where(q_params).order(grade: :asc)
    end

    private
    def set_new_order
      @order = current_client.orders.build
      @order.items.build
    end

  end
end
