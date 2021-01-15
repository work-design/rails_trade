module Trade
  class Admin::CashesController < Admin::BaseController
    before_action :set_cash, only: [:show, :edit, :update, :destroy]

    def index
      @cashes = Cash.order(id: :desc).page(params[:page])
    end

    def show
    end

    def edit
    end

    def update
      @cash.assign_attributes(cash_params)

      unless @cash.save
        render :edit, locals: { model: @cash }, status: :unprocessable_entity
      end
    end

    def destroy
      @cash.destroy
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
