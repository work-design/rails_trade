module Trade
  class Panel::ExchangeRatesController < Panel::BaseController
    before_action :set_exchange_rate, only: [:show, :edit, :update, :destroy]

    def index
      @exchange_rates = ExchangeRate.page(params[:page])
    end

    def new
      @exchange_rate = ExchangeRate.new
    end

    def create
      @exchange_rate = ExchangeRate.new(exchange_rate_params)

      unless @exchange_rate.save
        render :new, locals: { model: @exchange_rate }, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      @exchange_rate.assign_attributes(exchange_rate_params)

      unless @exchange_rate.save
        render :edit, locals: { model: @exchange_rate }, status: :unprocessable_entity
      end
    end

    def destroy
      @exchange_rate.destroy
    end

    private
    def set_exchange_rate
      @exchange_rate = ExchangeRate.find(params[:id])
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
