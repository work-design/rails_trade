module Trade
  class Admin::CardPrepaymentsController < Admin::BaseController
    before_action :set_card_template
    before_action :set_card_prepayment, only: [:show, :edit, :update, :destroy]

    def index
      @card_prepayments = @card_template.card_prepayments.page(params[:page])
    end

    def new
      @card_prepayment = @card_template.card_prepayments.build
    end

    def create
      @card_prepayment = @card_template.card_prepayments.build(card_prepayment_params)

      unless @card_prepayment.save
        render :new, locals: { model: @card_prepayment }, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      @card_prepayment.assign_attributes(card_prepayment_params)

      unless @card_prepayment.save
        render :edit, locals: { model: @card_prepayment }, status: :unprocessable_entity
      end
    end

    def destroy
      @card_prepayment.destroy
    end

    private
    def set_card_template
      @card_template = CardTemplate.find params[:card_template_id]
    end

    def set_card_prepayment
      @card_prepayment = CardPrepayment.find(params[:id])
    end

    def card_prepayment_params
      params.fetch(:card_prepayment, {}).permit(
        :amount,
        :token,
        :expire_at
      )
    end

  end
end
