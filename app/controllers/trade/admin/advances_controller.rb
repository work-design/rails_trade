module Trade
  class Admin::AdvancesController < Admin::BaseController
    before_action :set_wallet_template
    before_action :set_advance, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_advance, only: [:new, :create]
    before_action :set_card_templates, only: [:new, :create, :lawful_new, :edit, :update]

    def index
      @advances = @wallet_template.advances.order(amount: :asc).page(params[:page])
    end

    private
    def set_wallet_template
      @wallet_template = WalletTemplate.find params[:wallet_template_id]
    end

    def set_new_advance
      @advance = @wallet_template.advances.build(advance_params)
    end

    def set_advance
      @advance = @wallet_template.advances.find(params[:id])
    end

    def set_card_templates
      @card_templates = CardTemplate.default_where(default_params)
    end

    def advance_params
      p = params.fetch(:advance, {}).permit(
        :price,
        :amount,
        :wallet_template_id,
        :card_template_id,
        :open,
        :enabled,
        :logo
      )
      p.merge! default_form_params
    end
  end
end
