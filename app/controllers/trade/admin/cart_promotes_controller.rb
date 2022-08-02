module Trade
  class Admin::CartPromotesController < Admin::BaseController
    before_action :set_cart_promote, only: [:show, :edit, :update, :destroy, :actions]

    def index
      @card_promotes = @card_template.card_promotes.page(params[:page])
    end

    def new
      @cart_promote = @card_template.card_promotes.build
    end

    def create
      @cart_promote = @card_template.card_promotes.build(card_promote_params)

      unless @cart_promote.save
        render :new, locals: { model: @cart_promote }, status: :unprocessable_entity
      end
    end

    def update
      @cart_promote.edited = true
      super
    end

    private
    def set_card_template
      @card_template = CardTemplate.find params[:card_template_id]
    end

    def set_cart_promote
      @cart_promote = CartPromote.find(params[:id])
    end

    def card_promote_params
      params.fetch(:cart_promote, {}).permit(
        :income_min,
        :income_max,
        :promote_id
      )
    end

  end
end
