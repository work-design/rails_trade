module Trade
  class Admin::CashesController < Admin::BaseController
    before_action :set_cash, only: [:show, :edit, :update, :destroy]

    def index
      @cashes = Cash.order(id: :desc).page(params[:page])
    end

    private
    def set_cash
      @cash = Cash.find(params[:id])
    end

    def cash_params
      params.fetch(:cash, {}).permit(
        :account_bank,
        :account_name,
        :account_num
      )
    end

  end
end
