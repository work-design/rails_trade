module Trade
  class Admin::AdvancesController < Admin::BaseController
    before_action :set_card_template
    before_action :set_advance, only: [:show, :edit, :update, :destroy]

    def index
      @advances = @card_template.advances.order(id: :desc).page(params[:page])
    end

    def new
      @advance = @card_template.advances.build
    end

    def create
      @advance = @card_template.advances.build(advance_params)

      unless @advance.save
        render :new, locals: { model: @advance }, status: :unprocessable_entity
      end
    end

    private
    def set_card_template
      @card_template = CardTemplate.find params[:card_template_id]
    end

    def set_advance
      @advance = @card_template.advances.find(params[:id])
    end

    def advance_params
      params.fetch(:advance, {}).permit(
        :price,
        :amount,
        :state,
        :apple_product_id,
        :logo
      )
    end
  end
end
