class Vip::Admin::PayoutsController < Vip::Admin::BaseController
  before_action :set_payout, only: [:show, :edit, :update, :do_pay, :destroy]

  def index
    q_params = {}
    q_params.merge! params.permit(:id, :cash_id, :payout_uuid)
    @payouts = Payout.default_where(q_params).page(params[:page])
  end

  def new
    @payout = Payout.new
  end

  def create
    @payout = Payout.new(payout_params)

    if @payout.save
      render 'create'
    else
      render :new, locals: { model: @payout }, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @payout.assign_attributes(payout_params)

    unless @payout.save
      render :edit, locals: { model: @payout }, status: :unprocessable_entity
    end
  end

  def do_pay
    @payout.do_pay
    redirect_to admin_payouts_url(id: @payout.id), notice: 'Payout was successfully payed.'
  end

  def destroy
    @payout.destroy
  end

  private
  def set_payout
    @payout = Payout.find(params[:id])
  end

  def payout_params
    p = params.fetch(:payout, {}).permit(
      :actual_amount,
      :payout_uuid,
      :to_bank,
      :to_name,
      :to_identifier,
      :proof
    )
    p.merge! operator_id: current_member.id
    p
  end

end
