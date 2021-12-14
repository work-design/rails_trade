module Trade
  class Admin::PaymentStrategiesController < Admin::BaseController
    before_action :set_payment_strategy, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}

      @payment_strategies = PaymentStrategy.default_where(q_params)
    end

    def new
      @payment_strategy = PaymentStrategy.new
    end

    def create
      @payment_strategy = PaymentStrategy.new(payment_strategy_params)

      if @payment_strategy.save
        render 'create'
      else
        render :new, locals: { model: @payment_strategy }, status: :unprocessable_entity
      end
    end

    private
    def set_payment_strategy
      @payment_strategy = PaymentStrategy.find(params[:id])
    end

    def payment_strategy_params
      params.fetch(:payment_strategy, {}).permit(
        :name,
        :strategy,
        :period
      )
    end

  end
end
