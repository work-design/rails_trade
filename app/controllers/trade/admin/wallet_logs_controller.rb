module Trade
  class Admin::WalletLogsController < Admin::BaseController
    before_action :set_wallet_log, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:user_id, :wallet_id)

      @wallet_logs = WalletLog.default_where(q_params).order(id: :desc).page(params[:page])
    end

    def show
    end

    private
    def set_wallet_log
      @wallet_log = WalletLog.find(params[:id])
    end

  end
end
