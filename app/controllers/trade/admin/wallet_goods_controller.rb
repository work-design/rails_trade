module Trade
  class Admin::WalletGoodsController < Admin::BaseController
    before_action :set_wallet_template
    before_action :set_new_wallet_good, only: [:create]

    def index
      @wallet_goods = @wallet_template.wallet_goods.where(good_id: nil).order(good_type: :asc)
    end

    def new
      @wallet_good = @wallet_template.wallet_goods.build(good_type: params[:good_type])
    end

    private
    def set_wallet_template
      @wallet_template = WalletTemplate.find params[:wallet_template_id]
    end

    def set_new_wallet_good
      @wallet_good = @wallet_template.wallet_goods.build(wallet_good_params)
    end

    def wallet_good_params
      params.fetch(:wallet_good, {}).permit(
        :good_type
      )
    end

  end
end
