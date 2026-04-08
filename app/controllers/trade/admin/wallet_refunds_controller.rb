module Trade
  class Admin::WalletRefundsController < Admin::BaseController
    before_action :set_wallet
    before_action :set_wallet_refund, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_wallet_refund, only: [:new, :create]

    def index
      q_params = {}

      @wallet_refunds = @wallet.wallet_refunds.includes(refund_orders: :order).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def batch
      @payment = WalletPayment.init_with_order_ids params[:ids], params[:wallet_id]
    end

    private
    def set_wallet
      @wallet = Wallet.find params[:wallet_id]
    end

    def set_new_wallet_refund
      @wallet_refund = @wallet.wallet_refunds.build(wallet_refund_params)
      @wallet_refund.notified_at ||= Time.current
    end

    def set_wallet_refund
      @wallet_refund = WalletPayment.find(params[:id])
    end

    def wallet_refund_params
      params.fetch(:wallet_refund, {}).permit(
        :total_amount,
        :notified_at,
        :comment
      )
    end

  end
end
