class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :destroy]

  def index
    @users = User.page(params[:page])
  end

  def show
  end

  def destroy
    @user.destroy

    redirect_to admin_users_url
  end

  private

  def set_user
    @user = User.find params[:id]
  end

end
