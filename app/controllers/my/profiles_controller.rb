class My::ProfilesController < My::BaseController
   
  def index
    @user = current_user

    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    respond_to do |format|
      if @user.update user_params
        format.html { redirect_to user_me_url, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = current_user
    @user.destroy

    respond_to do |format|
      format.html { redirect_to people_url }
      format.json { head :no_content }
    end
  end

  private
  def user_params
    params[:user].permit(:email, :name)
  end
end
