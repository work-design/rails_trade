module Trade
  class Admin::CashGivensController < Admin::BaseController
    before_action :set_cash_given, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}.with_indifferent_access
      q_params.merge! params.permit(:cash_id)
      @cash_givens = CashGiven.default_where(q_params).page(params[:page])
    end

    def new
      @cash_given = CashGiven.new
    end

    def create
      @cash_given = CashGiven.new(cash_given_params)

      unless @cash_given.save
        render :new, locals: { model: @cash_given }, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      @cash_given.assign_attributes(cash_given_params)

      unless @cash_given.save
        render :edit, locals: { model: @cash_given }, status: :unprocessable_entity
      end
    end

    def destroy
      @cash_given.destroy
    end

    private
    def set_cash_given
      @cash_given = CashGiven.find(params[:id])
    end

    def cash_given_params
      params.fetch(:cash_given, {}).permit(
        :user,
        :amount,
        :note
      )
    end

  end
end
