module Trade
  class My::PayoutsController < My::BaseController

    def index
      @cash = current_user.cash
      @payouts = @cash.payouts.order(id: :desc).page(params[:page]).per(params[:per])
    end

    def list
      @cash = current_user.cash
      @payout_lists = RailsTrade.config.payout_list.map { |i| { requested_amount: i } }
    end

    def create
      @cash = current_user.cash
      @payout = @cash.payouts.build(payout_params)

      if @payout.save
        render 'show', status: :created
      else
        process_errors(@payout)
      end
    end

    private
    def payout_params
      params.fetch(:payout, {}).permit(
        :requested_amount
      )
    end

  end
end
