module Trade
  class My::CardTemplatesController < My::BaseController
    before_action :set_cart
    before_action :set_card_template, only: [:show]
    before_action :set_card_templates
    before_action :set_new_order, only: [:show]

    def index
      q_params = {}
      q_params.merge! default_params

      @card_templates = CardTemplate.default_where(q_params).order(grade: :asc)
    end

    def show
      @card = @cart.cards.formal.find_by(card_template_id: @card_template.id)
    end

    def code
      @card_template = CardTemplate.default_where(default_params).find_by(code: params[:id])
      @card = @cart.cards.find_by(card_template_id: @card_template.id)

      render :show
    end

    private
    def set_card_template
      @card_template = CardTemplate.default_where(default_params).find(params[:id])
    end

    def set_card_templates
      @card_templates = CardTemplate.default_where(default_params).order(grade: :asc)
    end

    def set_new_order
      @order = current_user.orders.build
      @order.items.build
    end

  end
end
