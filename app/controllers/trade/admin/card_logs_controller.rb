class Trade::Admin::CardLogsController < Trade::Admin::BaseController
  before_action :set_card
  before_action :set_card_log, only: [:show, :edit, :update]

  def index
    @card_logs = @card.card_logs.order(id: :desc).page(params[:page])
  end

  def show
  end

  def edit
  end

  def update
    @card_log.assign_attributes(card_log_params)

    unless @card_log.save
      render :edit, locals: { model: @card_log }, status: :unprocessable_entity
    end
  end

  private
  def set_card
    @card = Card.find params[:card_id]
  end

  def set_card_log
    @card_log = CardLog.find(params[:id])
  end

  def card_log_params
    params.fetch(:card_log, {}).permit(
      :title,
      :tag_str,
      :source_type,
      :source_id,
      :amount
    )
  end

end
