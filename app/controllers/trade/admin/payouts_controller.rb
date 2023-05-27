module Trade
  class Admin::PayoutsController < Admin::BaseController
    before_action :set_wallet
    before_action :set_payout, only: [:show, :edit, :update, :do_pay, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:id, :payout_uuid)

      @payouts = @wallet.payouts.default_where(q_params).page(params[:page])
    end

    def do_pay
      @payout.do_pay
    end

    private
    def set_wallet
      @wallet = Wallet.find params[:wallet_id]
    end

    def set_payout
      @payout = Payout.find(params[:id])
    end

    def payout_params
      p = params.fetch(:payout, {}).permit(
        :actual_amount,
        :payout_uuid,
        :to_bank,
        :to_name,
        :to_identifier,
        :proof
      )
      p.merge! operator_id: current_member.id
      p
    end

  end
end
