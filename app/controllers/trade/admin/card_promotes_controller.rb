module Trade
  class Admin::CardPromotesController < Admin::BaseController
    before_action :set_card_template
    before_action :set_card_promote, only: [:show, :edit, :update, :destroy]
    before_action :prepare_form, only: [:new, :edit]

    def index
      @card_promotes = @card_template.card_promotes.page(params[:page])
    end

    def new
      @card_promote = @card_template.card_promotes.build
    end

    def create
      @card_promote = @card_template.card_promotes.build(card_promote_params)

      unless @card_promote.save
        render :new, locals: { model: @card_promote }, status: :unprocessable_entity
      end
    end

    private
    def set_card_template
      @card_template = CardTemplate.find params[:card_template_id]
    end

    def set_card_promote
      @card_promote = CardPromote.find(params[:id])
    end

    def prepare_form
      @promotes = Promote.default_where(default_params)
    end

    def card_promote_params
      params.fetch(:card_promote, {}).permit(
        :income_min,
        :income_max,
        :promote_id
      )
    end

  end
end
