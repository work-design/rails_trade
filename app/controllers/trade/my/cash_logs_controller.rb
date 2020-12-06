class Vip::My::CashLogsController < Vip::My::BaseController

  def index
    @cash = current_user.cash
    @cash_logs = @cash.cash_logs.order(id: :desc).page(params[:page]).per(params[:per])
  end


end
