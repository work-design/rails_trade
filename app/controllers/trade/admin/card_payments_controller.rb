module Trade
  class Admin::CardPaymentsController < Admin::BaseController
    before_action :set_card
    before_action :set_card_payment, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}

      @card_payments = @card.card_payments.default_where(q_params).page(params[:page])
    end

    def new
      @card_payment = CardPayment.new
    end

    def create
      @card_payment = CardPayment.new(card_payment_params)

      unless @card_payment.save
        render :new, locals: { model: @card_payment }, status: :unprocessable_entity
      end
    end

    private
    def set_card
      @card = Card.find params[:card_id]
    end

    def set_card_payment
      @card_payment = CardPayment.find(params[:id])
    end

    def card_payment_params
      params.fetch(:card_payment, {}).permit(
        :total_amount,
        :refunded_amount,
        :created_at
      )
    end

  end
end
