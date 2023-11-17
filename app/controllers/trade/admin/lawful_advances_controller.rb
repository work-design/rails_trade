module Trade
  class Admin::LawfulAdvancesController < Admin::BaseController
    before_action :set_advance, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_advance, only: [:new, :create]
    before_action :set_card_templates, only: [:new, :create, :edit, :update]

    def index
      q_params = {
        lawful: true
      }
      q_params.merge! default_params

      @advances = Advance.default_where(q_params).order(amount: :asc).page(params[:page])
    end

    private
    def set_new_advance
      @advance = Advance.new(advance_params)
      @advance.lawful = true
    end

    def set_advance
      @advance = Advance.find(params[:id])
    end

    def set_card_templates
      @card_templates = CardTemplate.default_where(default_params)
    end

    def model_name
      'advance'
    end

    def advance_params
      p = params.fetch(:advance, {}).permit(
        :price,
        :amount,
        :wallet_template_id,
        :card_template_id,
        :open,
        :logo
      )
      p.merge! default_form_params
    end
  end
end
