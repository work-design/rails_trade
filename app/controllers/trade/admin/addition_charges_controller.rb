module Trade
  class Admin::AdditionChargesController < Admin::BaseController
    before_action :set_addition, except: [:options]
    before_action :set_addition_charge, only: [:edit, :update, :destroy]
    before_action :set_new_addition_charge, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! 'filter_min-lte': params[:value], 'filter_max-gte': params[:value]

      @addition_charges = @addition.addition_charges.default_where(q_params).order(min: :asc).page(params[:page]).per(params[:per])
    end

    def options
    end

    private
    def set_addition
      @addition = Addition.find params[:addition_id]
    end

    def set_addition_charge
      @addition_charge = @addition.addition_charges.find params[:id]
    end

    def set_new_addition_charge
      @addition_charge = @addition.addition_charges.build(addition_charge_params)
    end

    def addition_charge_params
      params.fetch(:addition_charge, {}).permit(
        :min,
        :max,
        :parameter,
        :base_price,
        :contain_min,
        :contain_max
      )
    end

  end
end
