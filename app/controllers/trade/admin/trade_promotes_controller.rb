module Trade
  class Admin::TradePromotesController < Admin::BaseController
    before_action :set_trade_promote, only: [:show, :edit, :update, :destroy]

    def index
      @trade_promotes = TradePromote.page(params[:page])
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

    def show
    end

    def edit
    end

    def update
      @trade_promote.assign_attributes(trade_promote_params)

      unless @trade_promote.save
        render :edit, locals: { model: @trade_promote }, status: :unprocessable_entity
      end
    end

    def destroy
      @trade_promote.destroy
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
