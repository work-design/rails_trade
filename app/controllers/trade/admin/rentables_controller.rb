module Trade
  class Admin::RentablesController < Admin::BaseController
    before_action :set_rentable

    def update
      @rentable.assign_attributes rentable_params
      @rentable.save
    end

    private
    def set_rentable
      @rentable = params[:rentable_type].constantize.find params[:rentable_id]
    end

    def rentable_params
      params.fetch(:rentable, {}).permit(
        :rent_unit
      )
    end

  end
end
