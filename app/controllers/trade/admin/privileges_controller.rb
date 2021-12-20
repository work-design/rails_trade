module Trade
  class Admin::PrivilegesController < Admin::BaseController
    before_action :set_card_template
    before_action :set_privilege, only: [:show, :edit, :update, :reorder, :destroy]
    before_action :set_new_privilege, only: [:new, :create]

    def index
      @privileges = @card_template.privileges.page(params[:page])
    end

    def reorder
      sort_array = params[:sort_array].select { |i| i.integer? }

      if params[:new_index] > params[:old_index]
        prev_one = @privilege.class.find(sort_array[params[:new_index].to_i - 1])
        @privilege.insert_at prev_one.position
      else
        next_ones = @privilege.class.find(sort_array[(params[:new_index].to_i + 1)..params[:old_index].to_i])
        next_ones.each do |next_one|
          next_one.insert_at @privilege.position
        end
      end
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
