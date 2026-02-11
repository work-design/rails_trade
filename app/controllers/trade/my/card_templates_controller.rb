module Trade
  class My::CardTemplatesController < My::BaseController
    before_action :set_cart
    before_action :set_card_template, only: [:show]
    before_action :set_card_templates
    before_action :set_new_order, only: [:index, :show]

    def index
      q_params = {}
      q_params.merge! default_params

      @cards = @cart.cards.formal
      @card_templates = CardTemplate.default_where(q_params).where.not(id: @cards.pluck(:card_template_id)).order(grade: :asc)
    end

    def show
      @card = @cart.cards.formal.find_by(card_template_id: @card_template.id)
    end

    def code
      @card_template = CardTemplate.default_where(default_params).find_by(code: params[:id])
      @card = @cart.cards.find_by(card_template_id: @card_template.id)

      render :show
    end

    def token
      @card_prepayment = CardPrepayment.find_by token: params[:token]
      @card = current_user.cards.find_or_initialize_by(card_template_id: @card_prepayment.card_template_id)
      @card.card_advances.build(amount: @card_prepayment.amount)
    end

    def token_create
      if token_params[:token]
        @card_prepayment = CardPrepayment.find_by token: token_params[:token]
        @card = current_cart.cards.find_or_initialize_by(card_template_id: @card_prepayment.card_template_id)
      end
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
