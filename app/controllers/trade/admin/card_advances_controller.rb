class Trade::Admin::CardAdvancesController < Trade::Admin::BaseController
  before_action :set_card_advance, only: [:show, :edit, :update, :destroy]

  def index
    q_params = {}
    q_params.merge! params.permit(:user_id, :wallet_id, :advance_id)

    @card_advances = CardAdvance.default_where(q_params).order(id: :desc).page(params[:page])
  end

  def new
    @card_advance = CardAdvance.new(user_id: params[:user_id], wallet_id: params[:wallet_id])
  end

  def create
    @card_advance = CardAdvance.new(card_advance_params)

    unless @card_advance.save
      render :new, locals: { model: @card_advance }, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @card_advance.assign_attributes(card_advance_params)

    unless @card_advance.save
      render :edit, locals: { model: @card_advance }, status: :unprocessable_entity
    end
  end

  def destroy
    @card_advance.destroy
  end

  private
  def set_card_advance
    @card_advance = CardAdvance.find(params[:id])
  end

  def card_advance_params
    params.fetch(:card_advance, {}).permit(
      :amount,
      :card_id,
      :state
    )
  end

end
