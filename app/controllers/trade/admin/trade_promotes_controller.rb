module Trade
  class Admin::TradePromotesController < Admin::BaseController
    before_action :set_trade_promote, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:trade_item_id, :cart_id)

      @trade_promotes = TradePromote.includes(:promote, :promote_charge).default_where(q_params).page(params[:page])
    end

    def new
      @trade_promote = TradePromote.new
    end

    def create
      @trade_promote = TradePromote.new(trade_promote_params)

      unless @trade_promote.save
        render :new, locals: { model: @trade_promote }, status: :unprocessable_entity
      end
    end

    private
    def set_trade_promote
      @trade_promote = TradePromote.find(params[:id])
    end

    def trade_promote_params
      p = params.fetch(:trade_promote, {}).permit(
        :amount,
        :note
      )
      p.merge! edited: true
    end

  end
end
