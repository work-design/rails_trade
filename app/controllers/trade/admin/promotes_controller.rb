module Trade
  class Admin::PromotesController < Admin::BaseController
    before_action :set_promote, only: [:show, :edit, :update, :destroy]
    before_action :set_units, only: [:edit, :upadte]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:scope, :id)

      @promotes = Promote.includes(:unit).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def create
      @promote = Promote.new(promote_params)

      if @promote.save
        @promote_charge = @promote.promote_charges.build
      else
        render :new, locals: { model: @promote }, status: :unprocessable_entity
      end
    end

    private
    def set_promote
      @promote = Promote.find(params[:id])
    end

    def promote_params
      p = params.fetch(:promote, {}).permit(
        :name,
        :code,
        :unit_code,
        :short_name,
        :description,
        :metering,
        :editable,
        extra: []
      )
      p.merge! default_form_params
    end

    def set_units
      @units = Unit.all
    end
  end
end
