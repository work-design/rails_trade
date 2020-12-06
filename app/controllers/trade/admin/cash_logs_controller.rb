class Vip::Admin::CashLogsController < Vip::Admin::BaseController
  before_action :set_cash_log, only: [:show, :edit, :update, :destroy]

  def index
    q_params = {}
    q_params.merge! params.permit(:user_id, :cash_id)

    @cash_logs = CashLog.includes(:user).default_where(q_params).order(id: :desc).page(params[:page])
  end

  def show
  end

  def edit
  end

  def update
    @cash_log.assign_attributes(cash_log_params)

    unless @cash_log.save
      render :edit, locals: { model: @cash_log }, status: :unprocessable_entity
    end
  end

  def destroy
    @cash_log.destroy
  end

  private
  def set_cash_log
    @cash_log = CashLog.find(params[:id])
  end

  def cash_log_params
    params.fetch(:cash_log, {}).permit(
      :title,
      :amount,
      :source_type,
      :source_id
    )
  end

end
