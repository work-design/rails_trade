class Vip::AdvancesController < Vip::BaseController
  before_action :set_card_template
  before_action :set_advance, only: [:show, :edit, :update, :destroy]

  def index
    @advances = @card_template.advances.order(id: :desc).page(params[:page])
  end

  def show
  end

  def new
    @advance = @card_template.advances.build
  end

  def edit
  end

  def create
    @advance = @card_template.advances.build(advance_params)

    unless @advance.save
      render :new, locals: { model: @advance }, status: :unprocessable_entity
    end
  end

  def update
    @advance.assign_attributes(advance_params)

    unless @advance.save
      render :edit, locals: { model: @advance }, status: :unprocessable_entity
    end
  end

  def destroy
    @advance.destroy
  end

  private
  def set_card_template
    @card_template = CardTemplate.find params[:card_template_id]
  end

  def set_advance
    @advance = Advance.find(params[:id])
  end

end
