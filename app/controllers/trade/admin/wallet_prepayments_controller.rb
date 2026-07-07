module Trade
  class Admin::WalletPrepaymentsController < Admin::BaseController
    before_action :set_wallet_template, except: [:all]
    before_action :set_filter_columns, only: [:index, :all]
    before_action :set_wallet_prepayment, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_wallet_prepayment, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! params.permit(:token, :secret)

      @wallet_prepayments = @wallet_template.wallet_prepayments.where(q_params).page(params[:page])
    end

    def all
      q_params = {}
      q_params.merge! params.permit(:token, :secret)

      @wallet_prepayments = WalletPrepayment.includes(:wallet_template).default_where(q_params).page(params[:page])
      if params.key?('used_at-desc')
        @wallet_prepayments = @wallet_prepayments.order('used_at DESC NULLS LAST')
      end
    end

    private
    def set_wallet_template
      @wallet_template = WalletTemplate.find params[:wallet_template_id]
    end

    def set_wallet_prepayment
      @wallet_prepayment = WalletPrepayment.find(params[:id])
    end

    def set_new_wallet_prepayment
      @wallet_prepayment = @wallet_template.wallet_prepayments.build(wallet_prepayment_params)
    end

    def filter_columns
      {
        'token' => { type: 'search', default: true },
        'secret' => { type: 'search', default: true }
      }
    end

    def wallet_prepayment_params
      params.fetch(:wallet_prepayment, {}).permit(
        :amount,
        :expire_at
      )
    end

  end
end
