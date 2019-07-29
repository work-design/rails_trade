class Trade::Admin::TradePromotesController < Trade::Admin::BaseController
  before_action :set_trade_promote, only: [:show, :edit, :update, :destroy]

  def index
    @trade_promotes = TradePromote.page(params[:page])
  end

  def new
    @trade_promote = TradePromote.new
  end

  def create
    @trade_promote = TradePromote.new(trade_promote_params)

    respond_to do |format|
      if @trade_promote.save
        format.html.phone
        format.html { redirect_to admin_trade_promotes_url }
        format.js { redirect_back fallback_location: admin_trade_promotes_url }
        format.json { render :show }
      else
        format.html.phone { render :new }
        format.html { render :new }
        format.js { redirect_back fallback_location: admin_trade_promotes_url }
        format.json { render :show }
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    @trade_promote.assign_attributes(trade_promote_params)

    respond_to do |format|
      if @trade_promote.save
        format.html.phone
        format.html { redirect_to admin_trade_promotes_url }
        format.js { redirect_back fallback_location: admin_trade_promotes_url }
        format.json { render :show }
      else
        format.html.phone { render :edit }
        format.html { render :edit }
        format.js { redirect_back fallback_location: admin_trade_promotes_url }
        format.json { render :show }
      end
    end
  end

  def destroy
    @trade_promote.destroy
    redirect_to admin_trade_promotes_url
  end

  private
  def set_trade_promote
    @trade_promote = TradePromote.find(params[:id])
  end

  def trade_promote_params
    params.fetch(:trade_promote, {}).permit(
      :amount,
      :note
    )
  end

end
