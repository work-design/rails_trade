class Vip::My::CardsController < Vip::My::BaseController
  before_action :set_card, only: [:show, :edit, :update, :destroy]

  def index
    q_params = {}
    q_params.merge! default_params
    q_params.merge! params.permit(:card_uuid, :card_template_id)
    @cards = Card.includes(:card_template).default_where(q_params).order(id: :desc).page(params[:page])
  end

  def new
    @card = Card.new
  end

  def create
    @card = Card.new(card_params)

    unless @card.save
      render :new, locals: { model: @card }, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @card.assign_attributes(card_params)

    unless @card.save
      render :edit, locals: { model: @card }, status: :unprocessable_entity
    end
  end

  def destroy
    @card.destroy
  end

  private
  def set_card
    @card = Card.find(params[:id])
  end

  def card_params
    params.fetch(:card, {}).permit(
      :type,
      :card_uuid,
      :effect_at,
      :expire_at,
      :amount,
      :income_amount
    )
  end

end
