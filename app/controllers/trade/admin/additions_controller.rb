module Trade
  class Admin::AdditionsController < Admin::BaseController
    before_action :set_addition, only: [:show, :edit, :update, :destroy]
    before_action :set_units, only: [:new, :create, :edit, :upadte]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:scope, :id)

      @additions = Addition.includes(:unit).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def create
      @addition = Addition.new(addition_params)

      if @addition.save
        @addition_charge = @addition.addition_charges.build
      else
        render :new, locals: { model: @addition }, status: :unprocessable_entity
      end
    end

    private
    def set_addition
      @addition = Addition.find(params[:id])
    end

    def addition_params
      p = params.fetch(:addition, {}).permit(
        :name,
        :code,
        :unit_code,
        :short_name,
        :description,
        :metering,
        :editable,
        extra: {}
      )
      p.merge! default_form_params
    end

    def set_units
      @units = Unit.all
    end
  end
end
