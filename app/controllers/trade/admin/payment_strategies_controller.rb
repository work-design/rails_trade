class Trade::Admin::PaymentStrategiesController < Trade::Admin::BaseController
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
      render 'create'
    else
      render :new, locals: { model: @payment_strategy }, status: :unprocessable_entity
    end
  end

  def update
    @payment_strategy.assign_attributes payment_strategy_params

    if @payment_strategy.save
      render 'update'
    else
      render :edit, locals: { model: @payment_strategy }, status: :unprocessable_entity
    end
  end

  def destroy
    @payment_strategy.destroy
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
