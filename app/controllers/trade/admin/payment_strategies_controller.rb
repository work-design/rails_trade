module Trade
  class Admin::PaymentStrategiesController < Admin::BaseController
    before_action :set_payment_strategy, only: [:show, :edit, :update, :destroy]
    before_action :set_new_payment_strategy, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! default_params

      @payment_strategies = PaymentStrategy.default_where(q_params)
    end

    private
    def set_payment_strategy
      @payment_strategy = PaymentStrategy.find(params[:id])
    end

    def set_new_payment_strategy
      @payment_strategy = PaymentStrategy.new(payment_strategy_params)
    end

    def payment_strategy_params
      p = params.fetch(:payment_strategy, {}).permit(
        :name,
        :strategy,
        :from_pay,
        :period
      )
      p.merge! default_form_params
    end

  end
end
