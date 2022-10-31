module Trade
  class Admin::RentChargesController < Admin::BaseController
    before_action :set_rentable, except: [:options]
    before_action :set_rent_charge, only: [:edit, :update, :destroy]
    before_action :set_new_rent_charge, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! 'filter_min-lte': params[:value], 'filter_max-gte': params[:value]

      @rent_charges = @rentable.rent_charges.default_where(q_params).order(min: :asc).page(params[:page]).per(params[:per])
    end

    def options
    end

    private
    def set_rentable
      if params[:rentable_type] && params[:rentable_id]
        @rentable = params[:rentable_type].constantize.find params[:rentable_id]
      end
    end

    def set_rent_charge
      @rent_charge = RentCharge.find params[:id]
    end

    def set_new_rent_charge
      if params[:rentable_type] && params[:rentable_id]
        @rent_charge = @rentable.rent_charges.build(rent_charge_params)
      else
        @rent_charge = RentCharge.new(rent_charge_params)
      end
    end

    def rent_charge_params
      params.fetch(:rent_charge, {}).permit(
        :min,
        :max,
        :parameter,
        :base_price,
        :contain_min,
        :contain_max,
        :rentable_type,
        :rentable_id
      )
    end

  end
end
