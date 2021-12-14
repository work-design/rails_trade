module Trade
  class Admin::CardLogsController < Admin::BaseController
    before_action :set_card
    before_action :set_card_log, only: [:show, :edit, :update]

    def index
      @card_logs = @card.card_logs.order(id: :desc).page(params[:page])
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
end
