class TheTradeAdmin::PaymentStrategiesController < TheTradeAdmin::BaseController
  before_action :set_payment_strategy, only: [:show, :edit, :update, :destroy]

  def index
    @payment_strategies = PaymentStrategy.all
  end

  def show
  end

  def new
    @payment_strategy = PaymentStrategy.new
  end

  def edit
  end

  def create
    @payment_strategy = PaymentStrategy.new(payment_strategy_params)

    if @payment_strategy.save
      redirect_to admin_payment_strategies_url, notice: 'Payment strategy was successfully created.'
    else
      render :new
    end
  end

  def update
    if @payment_strategy.update(payment_strategy_params)
      redirect_to admin_payment_strategies_url, notice: 'Payment strategy was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @payment_strategy.destroy
    redirect_to admin_payment_strategies_url, notice: 'Payment strategy was successfully destroyed.'
  end

  private
  def set_payment_strategy
    @payment_strategy = PaymentStrategy.find(params[:id])
  end

  def payment_strategy_params
    params.fetch(:payment_strategy, {}).permit(:name, :strategy, :period)
  end

end
