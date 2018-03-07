class TheTradeMy::BuyersController < TheTradeMy::BaseController
  before_action :set_buyer, only: [:show, :edit, :update]

  def show
    respond_to do |format|
      format.js
      format.html
      format.json { render json: @user }
    end
  end

  def edit
  end

  def update
    @buyer.assign_attributes(buyer_params)

    Buyer.transaction do
      current_user.save! if @buyer.new_record?
      @buyer.save!
    end

    if @buyer.saved_changes?
      redirect_to my_buyer_path, notice: 'Buyer 更新成功!'
    else
      render action: 'edit'
    end
  end

  private
  def set_buyer
    @buyer = current_buyer.buyer || current_buyer.build_buyer
  end

  def buyer_params
    params.fetch(:buyer, {}).permit!
  end

end
