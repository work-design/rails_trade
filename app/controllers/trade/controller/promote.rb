module Trade
  module Controller::Promote
    extend ActiveSupport::Concern

    included do
      before_action :set_promote, only: [:show, :edit, :update, :destroy]
    end

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:scope, :id)

      @promotes = Promote.default_where(q_params).order(id: :desc).page(params[:page])
    end

    def new
      @promote = Promote.new
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
        :short_name,
        :description,
        :scope,
        :metering,
        :editable,
        extra: []
      )
      p.merge! default_form_params
    end
  end
end
