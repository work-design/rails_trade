module Trade
  class Admin::PurchasesController < Admin::BaseController
    before_action :set_card_template
    before_action :set_advance, only: [:show, :edit, :update, :destroy]

    def index
      @purchases = @card_template.purchases.order(id: :desc).page(params[:page])
    end

    def new
      @purchase = @card_template.purchases.build
    end

    def create
      @purchase = @card_template.purchases.build(advance_params)

      unless @purchase.save
        render :new, locals: { model: @purchase }, status: :unprocessable_entity
      end
    end

    private
    def set_card_template
      @card_template = CardTemplate.find params[:card_template_id]
    end

    def set_advance
      @purchase = @card_template.purchases.find(params[:id])
    end

    def advance_params
      params.fetch(:purchase, {}).permit(
        :price,
        :title,
        :days,
        :months,
        :years,
        :note,
        :default
      )
    end
  end
end
