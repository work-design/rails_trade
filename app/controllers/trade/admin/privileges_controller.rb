module Trade
  class Admin::PrivilegesController < Admin::BaseController
    before_action :set_card_template
    before_action :set_privilege, only: [:show, :edit, :update, :destroy]

    def index
      @privileges = @card_template.privileges.page(params[:page])
    end

    private
    def set_new_privilege
      @privilege = @card_template.privileges.build(privilege_params)
    end

    def set_privilege
      @privilege = @card_template.privileges.find params[:id]
    end

    def set_card_template
      @card_template = CardTemplate.find params[:card_template_id]
    end

    def privilege_params
      params.fetch(:privilege, {}).permit(
        :name,
        :amount,
        :logo
      )
    end

  end
end
