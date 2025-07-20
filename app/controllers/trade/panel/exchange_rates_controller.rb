module Trade
  class Panel::ExchangeRatesController < Panel::BaseController
    before_action :set_exchange_rate, only: [:show, :edit, :update, :destroy]
    before_action :set_new_exchange_rate, only: [:new, :create]

    def index
      @exchange_rates = ExchangeRate.page(params[:page])
    end

    private
    def set_exchange_rate
      @exchange_rate = ExchangeRate.find(params[:id])
    end

    def set_new_exchange_rate
      @exchange_rate = ExchangeRate.new(exchange_rate_params)
    end

    def exchange_rate_params
      params.fetch(:exchange_rate, {}).permit(
        :from,
        :to,
        :rate
      )
    end

  end
end
