module Trade
  class Admin::WalletTemplatesController < Admin::BaseController
    before_action :set_wallet_template, only: [:show, :advance_options, :edit, :update, :destroy]

    def index
      q_params = {
        enabled: true
      }
      q_params.merge! 'id-desc': 1 unless (params.keys & ['wallets_count-desc', 'wallet_prepayments_count-desc']).present?
      q_params.merge! default_params
      q_params.merge! params.permit(:name, :code, :enabled, :unit, 'wallets_count-desc', 'wallet_prepayments_count-desc', 'name-like')

      @wallet_templates = WalletTemplate.includes(:wallet_goods, logo_attachment: :blob).default_where(q_params).page(params[:page]).per(params[:per])
    end

    def new
      @wallet_template = WalletTemplate.new
      @wallet_template.advances.build
    end

    def advance_options
      @advances = @wallet_template.advances
    end

    private
    def set_wallet_template
      @wallet_template = WalletTemplate.find(params[:id])
    end

    def filter_columns
      {
        'enabled' => { type: 'dropdown', default: true },
        'unit' => { type: 'dropdown', default: true },
        'name-like' => { type: 'search', default: true },
        'code' => { type: 'search', default: true }
      }
    end

    def wallet_template_params
      p = params.fetch(:wallet_template, {}).permit(
        :name,
        :description,
        :unit,
        :unit_kind,
        :code,
        :enabled,
        :hot,
        :digit,
        :logo,
        :limit,
        advances_attributes: [:amount, :price, :id]
      )
      p.merge! default_form_params
    end

  end
end
