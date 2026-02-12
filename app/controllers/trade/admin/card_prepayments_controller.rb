module Trade
  class Admin::CardPrepaymentsController < Admin::BaseController
    before_action :set_card_template
    before_action :set_card_prepayment, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_card_prepayment, only: [:new, :create]

    def index
      @card_prepayments = @card_template.card_prepayments.page(params[:page])
    end

    private
    def set_card_template
      @card_template = CardTemplate.find params[:card_template_id]
    end

    def set_card_prepayment
      @card_prepayment = @card_template.card_prepayments.find(params[:id])
    end

    def set_new_card_prepayment
      @card_prepayment = @card_template.card_prepayments.build(card_prepayment_params)
    end

    def card_prepayment_params
      params.fetch(:card_prepayment, {}).permit(
        :years,
        :months,
        :days,
        :expire_at
      )
    end

  end
end
